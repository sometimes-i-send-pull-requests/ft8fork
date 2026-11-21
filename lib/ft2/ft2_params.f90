module ft2_params
  implicit none

  ! LDPC (128,90) code
  integer, parameter :: KK=90                !Information bits (77 + CRC13)
  integer, parameter :: ND=128               !Data symbols
  integer, parameter :: NS=16                !Sync symbols (2x8)
  integer, parameter :: NN=NS+ND             !Total channel symbols (144)
  integer, parameter :: NSPS=160             !Samples per symbol at 12000 S/s
  integer, parameter :: NZ=NSPS*NN           !Samples in full 1.92 s waveform (23040)
  integer, parameter :: NMAX=30000           !Samples in iwave (2.5*12000)
  integer, parameter :: NFFT1=400, NH1=NFFT1/2 !Length of FFTs for symbol spectra
  integer, parameter :: NSTEP=NSPS/4         !Rough time-sync step size
  integer, parameter :: NHSYM=NMAX/NSTEP-3   !Number of symbol spectra (1/4-sym steps)
  integer, parameter :: NDOWN=16             !Downsample factor
end module ft2_params
