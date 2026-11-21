# Fortran Modernization TODO

Small, self-contained tasks. Do one per commit, keep the build green.
Add worthwhile follow-on ideas here as they come up.

When giving a file `implicit none`, bare `parameter (...)` statements are
implicitly typed and must be converted to explicit declarations (e.g.
`integer, parameter ::`).

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

## Add `implicit none` and declare implicit locals

- Turn lib/mskrtd.f90 into a module with `implicit none` (and remove its `go to`s).
- Add `implicit none` to module packjt77 and type its bare `parameter` statements.
- Add `implicit none` to the jt65_decode module and declare its implicit locals.
- Turn lib/downsam9.f90, lib/sync9.f90 and lib/sync9w.f90 into modules with `implicit none`.

## Other control-flow / robustness cleanups

- Replace the `stop` statements that only silence warnings with proper error handling (lib/jt65_decode.f90, lib/decoder.f90).
- Revisit the single-pass `do` workaround in lib/decoder.f90 if the gfortran block-construct bug is fixed.
- Turn lib/ft8/ft8_params.f90, lib/ft4/ft4_params.f90 and lib/fst4/fst4_params.f90 into modules.
