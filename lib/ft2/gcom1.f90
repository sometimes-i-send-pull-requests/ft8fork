module gcom1
  implicit none

  integer, parameter :: NRING=230400  !Ring buffer at 12000 samples/sec
  integer, parameter :: NTZ=23040     !144*160
  integer, parameter :: NMAX=30000    !2.5*12000

  real snrdb
  integer ndevin         !Device# for audio input
  integer ndevout        !Device# for audio output
  integer iwrite         !Pointer to Rx ring buffer
  integer itx            !Pointer to Tx buffer
  integer ngo            !Set to 0 to terminate audio streams
  integer nTransmitting  !Actually transmitting?
  integer nTxOK          !OK to transmit?
  integer nport          !COM port for PTT
  integer ntxed
  logical tx_once        !Transmit one message, then exit
  logical ltx(5)         !True if msg i has been transmitted
  logical lrx(5)         !True if msg i has been received
  logical autoseq
  logical QSO_in_progress
  integer*2 y1(NRING)    !Ring buffer for audio channel 0
  integer*2 y2(NRING)    !Ring buffer for audio channel 1
  integer*2 iwave(NTZ+3*1152)  !Data for Tx audio
  character*6 mycall
  character*6 hiscall
  character*6 hiscall_next
  character*4 mygrid
  character*3 exch
  character*37 txmsg

end module gcom1
