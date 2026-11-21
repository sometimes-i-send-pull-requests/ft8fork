#include "Jt9Decoder.hpp"

#include <cstddef>
#include <cstring>

#include <QMutexLocker>
#include <QtConcurrent/QtConcurrentRun>

#include "commons.h"

extern "C"
{
  // Entry points provided by the Fortran decoder library.
  void jt9_session_init ();
  void jt9_session_configure (char const * exe_dir, char const * data_dir
                              , char const * temp_dir, char const * share_dir);
  void jt9_decode_once (void * data, int nfsample);

  // Installs the in-process sink for decoded output lines.
  void set_line_output (void (*handler) (char const *));
  void clear_line_output ();
}

namespace
{
  // The Fortran output handler carries no user data, so the active decoder is
  // tracked here.  Only one decoder exists at a time.
  Jt9Decoder * active_decoder = nullptr;

  extern "C" void jt9_line_handler (char const * text)
  {
    if (active_decoder)
      {
        active_decoder->handleLine (text);
      }
  }
}

Jt9Decoder::Jt9Decoder (QObject * parent)
  : QObject {parent}
  , m_notify_pending {false}
  , m_busy {false}
  , m_data {new dec_data {}}
  , m_started {false}
{
}

Jt9Decoder::~Jt9Decoder ()
{
  stop ();
}

void Jt9Decoder::start (QString const& exe_dir, QString const& data_dir
                        , QString const& temp_dir, QString const& share_dir)
{
  auto const exe = exe_dir.toLocal8Bit ();
  auto const data = data_dir.toLocal8Bit ();
  auto const temp = temp_dir.toLocal8Bit ();
  auto const share = share_dir.toLocal8Bit ();

  active_decoder = this;
  jt9_session_init ();
  jt9_session_configure (exe.constData (), data.constData ()
                         , temp.constData (), share.constData ());
  set_line_output (&jt9_line_handler);
  m_started = true;
}

void Jt9Decoder::submit (dec_data const& data)
{
  if (m_busy)
    {
      return;
    }

  if (data.params.newdat)
    {
      std::memcpy (m_data.get (), &data, sizeof (dec_data));
    }
  else
    {
      // Only the parameters have changed, so keep the previously captured
      // sample and spectrum buffers that belong to the same interval.
      auto const offset = offsetof (dec_data, params);
      std::memcpy (reinterpret_cast<char *> (m_data.get ()) + offset
                   , reinterpret_cast<char const *> (&data) + offset
                   , sizeof (dec_data) - offset);
    }

  startDecode ();
}

void Jt9Decoder::startDecode ()
{
  if (m_busy)
    {
      return;
    }

  m_busy = true;
  m_future = QtConcurrent::run ([this] {runDecode ();});
}

void Jt9Decoder::stop ()
{
  if (m_future.isRunning ())
    {
      m_future.waitForFinished ();
    }

  if (m_started)
    {
      clear_line_output ();
      m_started = false;
    }

  if (active_decoder == this)
    {
      active_decoder = nullptr;
    }
}

void Jt9Decoder::runDecode ()
{
  jt9_decode_once (m_data.get (), RX_SAMPLE_RATE);
  m_busy = false;
}

void Jt9Decoder::handleLine (char const * text)
{
  {
    QMutexLocker locker {&m_mutex};
    m_lines.enqueue (QByteArray {text});
  }

  // Coalesce wake-ups: the flag is cleared when the queued notification runs.
  if (!m_notify_pending.exchange (true))
    {
      QMetaObject::invokeMethod (this, "notifyReadyRead", Qt::QueuedConnection);
    }
}

void Jt9Decoder::notifyReadyRead ()
{
  m_notify_pending = false;
  Q_EMIT readyRead ();
}

bool Jt9Decoder::canReadLine ()
{
  QMutexLocker locker {&m_mutex};
  return !m_lines.isEmpty ();
}

QByteArray Jt9Decoder::readLine ()
{
  QMutexLocker locker {&m_mutex};
  return m_lines.isEmpty () ? QByteArray {} : m_lines.dequeue ();
}
