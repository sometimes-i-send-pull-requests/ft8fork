# Fortran Modernization TODO

Small, self-contained tasks. Do one per commit, keep the build green.
Add worthwhile follow-on ideas here as they come up.

## Replace remaining `go to` flow control

- Replace `go to` in lib/options.f90.

## Add `implicit none` and declare implicit locals

- Add `implicit none` to module packjt and declare its implicit locals.
- Turn lib/mskrtd.f90 into a module with `implicit none` (and remove its `go to`s).

## Other control-flow / robustness cleanups

- Replace labeled `end=`/`err=` I/O branches with `iostat=` and structured handling (lib/decoder.f90, lib/fst4_decode.f90, lib/q65_decode.f90).
- Replace the `stop` statements that only silence warnings with proper error handling (lib/jt65_decode.f90, lib/decoder.f90).
- Revisit the single-pass `do` workaround in lib/decoder.f90 if the gfortran block-construct bug is fixed.
