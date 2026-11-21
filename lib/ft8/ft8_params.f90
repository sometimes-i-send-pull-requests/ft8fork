! LDPC (174,91) code
integer, parameter :: KK=91                !Information bits (77 + CRC14)
integer, parameter :: ND=58                !Data symbols
integer, parameter :: NS=21                !Sync symbols (3 @ Costas 7x7)
integer, parameter :: NN=NS+ND             !Total channel symbols (79)
integer, parameter :: NSPS=1920            !Samples per symbol at 12000 S/s
integer, parameter :: NZ=NSPS*NN           !Samples in full 15 s waveform (151,680)
integer, parameter :: NMAX=15*12000        !Samples in iwave (180,000)
integer, parameter :: NFFT1=2*NSPS, NH1=NFFT1/2 !Length of FFTs for symbol spectra
integer, parameter :: NSTEP=NSPS/4         !Rough time-sync step size
integer, parameter :: NHSYM=NMAX/NSTEP-3   !Number of symbol spectra (1/4-sym steps)
integer, parameter :: NDOWN=60             !Downsample factor
