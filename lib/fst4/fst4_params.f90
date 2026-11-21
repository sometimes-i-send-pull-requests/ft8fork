! FST4
! LDPC(240,101)/CRC24 code, five 8x4 sync

integer, parameter :: KK=77                    !Information bits (77 + CRC24)
integer, parameter :: ND=120                   !Data symbols
integer, parameter :: NS=40                    !Sync symbols 
integer, parameter :: NN=NS+ND                 !Sync and data symbols (160)
