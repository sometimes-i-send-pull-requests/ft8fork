module wspr_params
  implicit none

  integer, parameter :: NN=162
  integer, parameter :: NSPS0=8192         !Samples per symbol at 12000 S/s
  integer, parameter :: NDOWN=32
  integer, parameter :: NSPS=NSPS0/NDOWN
  integer, parameter :: NZ=NSPS*NN         !Samples in waveform at 12000 S/s
  integer, parameter :: NZ0=NSPS0*NN       !Samples in waveform at 375 S/s
  integer, parameter :: NMAX=120*12000     !Samples in waveform at 375 S/s

! Define the sync vector:
  integer*1, parameter :: sync(162) = (/                          &
       1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,   &
       0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,   &
       0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,   &
       1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,   &
       0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,   &
       0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,   &
       0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,   &
       0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,   &
       0,0 /)

end module wspr_params
