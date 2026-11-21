#ifndef JT9_DECODER_HPP__
#define JT9_DECODER_HPP__

#include <atomic>
#include <memory>

#include <QByteArray>
#include <QFuture>
#include <QMutex>
#include <QObject>
#include <QQueue>
#include <QString>

struct dec_data;

//
// class Jt9Decoder - Run the jt9 decoder for one interval at a time.
//
// Decoding is performed in-process on a worker thread.  Decoded output is
// delivered as a line-oriented stream, with readyRead() signalling that new
// output is available.  Only one decode runs at a time; further requests
// made while a decode is in progress are ignored.
//
class Jt9Decoder
  : public QObject
{
  Q_OBJECT;

public:
  explicit Jt9Decoder (QObject * parent = nullptr);
  ~Jt9Decoder () override;

  // Configure the decoder's data directories and install the output handler.
  void start (QString const& exe_dir, QString const& data_dir
              , QString const& temp_dir, QString const& share_dir);

  // Decode the interval described by data.
  void submit (dec_data const& data, qint32 ihsym);

  // Decode the most recently submitted interval again.
  void startDecode (qint32 ihsym);

  // An in-progress decode cannot be abandoned; it always runs to completion.
  void requestEarlyExit (qint32 ihsym);

  // Decoding has already finished by the time its output has been consumed,
  // so no acknowledgement is required.
  void acknowledgeDone (qint32 ihsym);

  // Wait for any in-progress decode and remove the output handler.
  void stop ();

  // Decoded output as a line-oriented stream.
  bool canReadLine ();
  QByteArray readLine ();

  // Receive a decoded output line from the Fortran output handler.
  void handleLine (char const * text);

signals:
  void readyRead ();

private slots:
  void notifyReadyRead ();

private:
  void runDecode ();

  QMutex m_mutex;
  QQueue<QByteArray> m_lines;
  std::atomic<bool> m_notify_pending;
  std::atomic<bool> m_busy;
  QFuture<void> m_future;
  std::unique_ptr<dec_data> m_data;
  bool m_started;
};

#endif
