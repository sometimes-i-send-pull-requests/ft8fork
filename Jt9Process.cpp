#include "Jt9Process.hpp"

#include <cstring>

#include <QProcessEnvironment>
#include <QThread>

#include "commons.h"

namespace
{
  // values understood by the decoder's shared memory control word
  int const start_command = 1;
  int const shutdown_command = 999;
}

Jt9Process::Jt9Process (QString const& key, QObject * parent)
  : QObject {parent}
{
  m_shared_memory.setKey (key);

  connect (&m_process, &QProcess::readyReadStandardOutput
           , this, &Jt9Process::readyRead);
#if QT_VERSION < QT_VERSION_CHECK (5, 6, 0)
  connect (&m_process, static_cast<void (QProcess::*) (QProcess::ProcessError)> (&QProcess::error)
           , this, &Jt9Process::errorOccurred);
#else
  connect (&m_process, &QProcess::errorOccurred
           , this, &Jt9Process::errorOccurred);
#endif
  connect (&m_process
           , static_cast<void (QProcess::*) (int, QProcess::ExitStatus)> (&QProcess::finished)
           , this, &Jt9Process::finished);
}

Jt9Process::~Jt9Process ()
{
  stop ();
}

bool Jt9Process::start (QString const& program, QStringList const& arguments
                        , QProcessEnvironment const& environment)
{
  if (!establishSharedMemory ())
    {
      return false;
    }

  setIPC (0, 0, 0);             // initialize the IPC variables

  m_process.setProcessEnvironment (environment);
  m_process.start (program, arguments
                   , QIODevice::ReadWrite | QIODevice::Unbuffered);
  return true;
}

bool Jt9Process::establishSharedMemory ()
{
  // try and shut down any decoder left over from a previous run; the
  // presence of the shared memory segment implies an orphaned decoder
  for (int i = 3; i; --i)       // three tries to close an old decoder
    {
      if (!m_shared_memory.attach ())
        {
          break;                // good to go
        }
      if (auto * dd = reinterpret_cast<dec_data *> (m_shared_memory.data ()))
        {
          m_shared_memory.lock ();
          dd->ipc[1] = shutdown_command;
          m_shared_memory.unlock ();
        }
      m_shared_memory.detach (); // start again
      QThread::sleep (1);       // wait for the decoder to end
    }

  if (m_shared_memory.attach ())
    {
      m_shared_memory.detach ();
      m_failure_reason = tr ("Failed to close orphaned jt9 process");
      return false;
    }

  if (!m_shared_memory.create (sizeof (dec_data)))
    {
      m_failure_reason = tr ("Unable to create shared memory segment: %1")
        .arg (m_shared_memory.errorString ());
      return false;
    }

  m_shared_memory.lock ();
  std::memset (m_shared_memory.data (), 0, sizeof (dec_data));
  m_shared_memory.unlock ();
  return true;
}

void Jt9Process::submit (dec_data const& data, qint32 ihsym)
{
  auto * to = reinterpret_cast<char *> (m_shared_memory.data ());
  if (!to)
    {
      return;
    }

  auto const * from = reinterpret_cast<char const *> (&data);
  int size {sizeof (dec_data)};
  if (!data.params.newdat)
    {
      // only the parameters change, so skip the sample and spectrum buffers
      int const offset {offsetof (dec_data, params.nutc)};
      to += offset;
      from += offset;
      size -= offset;
    }

  m_shared_memory.lock ();
  std::memcpy (to, from, qMin (m_shared_memory.size (), size));
  m_shared_memory.unlock ();

  setIPC (ihsym, start_command, -1);
}

void Jt9Process::startDecode (qint32 ihsym)
{
  setIPC (ihsym, start_command, -1);
}

void Jt9Process::requestEarlyExit (qint32 ihsym)
{
  setIPC (ihsym, -1, -1);
}

void Jt9Process::acknowledgeDone (qint32 ihsym)
{
  setIPC (ihsym, -1, 1);
}

void Jt9Process::stop ()
{
  if (auto * dd = reinterpret_cast<dec_data *> (m_shared_memory.data ()))
    {
      m_shared_memory.lock ();
      dd->ipc[1] = shutdown_command;
      m_shared_memory.unlock ();
    }

  if (QProcess::NotRunning != m_process.state ())
    {
      if (!m_process.waitForFinished (1000))
        {
          m_process.close ();
        }
    }

  if (m_shared_memory.isAttached ())
    {
      m_shared_memory.detach ();
    }
}

bool Jt9Process::canReadLine ()
{
  return m_process.canReadLine ();
}

QByteArray Jt9Process::readLine ()
{
  return m_process.readLine ();
}

QString Jt9Process::commandLine () const
{
  QStringList arguments;
  for (auto argument : m_process.arguments ())
    {
      if (argument.contains (' '))
        {
          argument = '"' + argument + '"';
        }
      arguments << argument;
    }
  return m_process.program () + ' ' + arguments.join (' ');
}

QString Jt9Process::errorString () const
{
  return m_process.errorString ();
}

QByteArray Jt9Process::readAllStandardError ()
{
  return m_process.readAllStandardError ();
}

QString Jt9Process::failureReason () const
{
  return m_failure_reason;
}

void Jt9Process::setIPC (qint32 n, qint32 istart, qint32 idone)
{
  if (auto * dd = reinterpret_cast<dec_data *> (m_shared_memory.data ()))
    {
      m_shared_memory.lock ();
      dd->ipc[0] = n;
      if (istart >= 0)
        {
          dd->ipc[1] = istart;
        }
      if (idone >= 0)
        {
          dd->ipc[2] = idone;
        }
      m_shared_memory.unlock ();
    }
}
