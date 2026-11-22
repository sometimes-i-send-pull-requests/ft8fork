# Fortran Modernization TODO

Small, self-contained tasks. Do one per commit, keep the build green.
Add worthwhile follow-on ideas here as they come up.

When giving a file `implicit none`, bare `parameter (...)` statements are
implicitly typed and must be converted to explicit declarations (e.g.
`integer, parameter ::`).

## Replace `include`s with module usage

Test data (used only by test programs):

- Turn testmsg.f90, ft8_testmsg.f90, ft4_testmsg.f90 and msk144_testmsg.f90 into modules.

## Replace remaining `go to` flow control

- Replace `go to` in lib/options.f90.
- Replace `go to` in lib/jt9.f90.
- Replace `go to` in lib/jt9_decode.f90.
- Replace `go to` in lib/symspec.f90.
- Replace `go to` in lib/filbig.f90.
- Replace `go to` in lib/four2a.f90.
- Replace `go to` in lib/get_q3list.f90.
- Replace `go to` in lib/refspectrum.f90.
- Replace `go to` in lib/ft8var/cwfilter.f90, lib/ft8var/filbigvar.f90 and lib/ft8var/four2avar.f90.
- Replace `go to` in the chkfft diagnostic programs (lib/chkfft.f90, lib/chkfft2.f90 and lib/chkfft3.f90).

## Build hygiene

- Remove the unused map65/libm65/wavhdr.f90 (its module has no users in map65).
- Deduplicate the prefix/suffix table shared by lib/pfx.f90 and map65/libm65/pfx.f90.
- Decide whether to build or remove the legacy Fortran programs lib/ft2/ft2.f90 and lib/wsprd/wsprsimf.f90 (not currently in CMake).
- Decide whether to build or remove the legacy SuperFox programs lib/superfox/sfrx.f90 and lib/superfox/sftx.f90 (not currently in CMake).
- Decide whether to remove the unused ldpc_128_90_b_* tables and ldpc_174_91_c_colorder.f90 (no current consumers).

## Other control-flow / robustness cleanups

- Replace the `stop` statements that only silence warnings with proper error handling (lib/jt65_decode.f90, lib/decoder.f90).
- Revisit the single-pass `do` workaround in lib/decoder.f90 if the gfortran block-construct bug is fixed.
- Make the id2 array bounds consistent between lib/fast9.f90 and its callers (the dummy uses assumed size 0:* to keep 0-based access of the callers' arrays).
