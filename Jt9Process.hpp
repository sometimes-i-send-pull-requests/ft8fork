#ifndef JT9_PROCESS_HPP__
#define JT9_PROCESS_HPP__

#include <QObject>
#include <QSharedMemory>
#include <QString>
#include <QStringList>

#include "NonInheritingProcess.hpp"

struct dec_data;
class QProcessEnvironment;

//
// class Jt9Process - Manage a jt9 decoder sub-process and the shared memory
//                    segment through which decode requests are passed to it.
//
// The decoder attaches to a shared memory segment keyed by the application
// name and waits for a request to be written there.  This class owns both the
// segment and the sub-process and presents the request/acknowledgement
// handshake as ordinary method calls.  Decoded output is made available as a
// line-oriented stream and process failures are reported via signals.
//
class Jt9Process
  : public QObject
{
  Q_OBJECT;

public:
  explicit Jt9Process (QString const& key, QObject * parent = nullptr);
  ~Jt9Process () override;

  // Establish the shared memory segment (terminating any decoder left over
  // from a previous run) and start the decoder sub-process.  Returns false if
  // the segment could not be established or the process could not be started,
  // in which case failureReason() describes the failure.
  bool start (QString const& program, QStringList const& arguments
              , QProcessEnvironment const& environment);

  // Copy decode parameters into the shared memory segment and ask the decoder
  // to begin.
  void submit (dec_data const& data, qint32 ihsym);

  // Ask the decoder to begin using the parameters already in the segment.
  void startDecode (qint32 ihsym);

  // Allow the decoder to abandon a decode that is taking too long.
  void requestEarlyExit (qint32 ihsym);

  // Acknowledge that the decoder's output has been consumed, freeing it to
  // accept the next request.
  void acknowledgeDone (qint32 ihsym);

  // Ask the decoder to terminate and detach the shared memory segment.  Also
  // performed by the destructor.
  void stop ();

  // Read the decoder's standard output as a line-oriented stream.
  bool canReadLine ();
  QByteArray readLine ();

  // Diagnostics for a failed or failing decoder process.
  QString commandLine () const;
  QString errorString () const;
  QByteArray readAllStandardError ();
  QString failureReason () const;

signals:
  void readyRead ();
  void finished (int exitCode, QProcess::ExitStatus exitStatus);
  void errorOccurred (QProcess::ProcessError error);

private:
  bool establishSharedMemory ();
  void setIPC (qint32 n, qint32 istart, qint32 idone);

  QString m_failure_reason;
  QSharedMemory m_shared_memory;
  NonInheritingProcess m_process;
};

#endif
