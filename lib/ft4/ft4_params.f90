module ft4_params
  implicit none

  ! FT4
  ! LDPC(174,91) code, four 4x4 Costas arrays for sync, ramp-up and ramp-down symbols

  integer, parameter :: KK=91                  !Information bits (77 + CRC14)
  integer, parameter :: ND=87                  !Data symbols
  integer, parameter :: NS=16                  !Sync symbols
  integer, parameter :: NN=NS+ND               !Sync and data symbols (103)
  integer, parameter :: NN2=NS+ND+2            !Total channel symbols (105)
  integer, parameter :: NSPS=576               !Samples per symbol at 12000 S/s
  integer, parameter :: NZ=NSPS*NN             !Sync and Data samples (59328)
  integer, parameter :: NZ2=NSPS*NN2           !Total samples in shaped waveform (60480)
  integer, parameter :: NMAX=21*3456           !Samples in iwave (72576)
  integer, parameter :: NFFT1=2304, NH1=NFFT1/2 !Length of FFTs for symbol spectra
  integer, parameter :: NSTEP=NSPS             !Coarse time-sync step size
  integer, parameter :: NHSYM=(NMAX-NFFT1)/NSTEP !Number of symbol spectra (1/4-sym steps)
  integer, parameter :: NDOWN=18               !Downsample factor
end module ft4_params
