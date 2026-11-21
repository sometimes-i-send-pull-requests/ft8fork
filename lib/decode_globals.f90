module decode_globals
  implicit none

  ! FFTW plan tuning, set from the command line in jt9.
  integer :: npatience = 1
  integer :: nthreads = 1

  ! Decoder statistics counters.
  integer :: ntry65a = 0
  integer :: ntry65b = 0
  integer :: n65a = 0
  integer :: n65b = 0
  integer :: num9 = 0
  integer :: numfano = 0

end module decode_globals
