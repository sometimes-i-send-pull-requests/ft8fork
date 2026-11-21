# Fortran Modernization TODO

Small, self-contained tasks. Do one per commit, keep the build green.
Add worthwhile follow-on ideas here as they come up.

## Replace remaining `go to` flow control

- Replace `go to` in lib/options.f90.

## Add `implicit none` and declare implicit locals

- Turn lib/mskrtd.f90 into a module with `implicit none` (and remove its `go to`s).

## Declaration cleanups

- Replace bare `parameter (...)` statements (implicitly typed) with explicit `integer, parameter ::` declarations when giving a file `implicit none`.

## Other control-flow / robustness cleanups

- Replace the `stop` statements that only silence warnings with proper error handling (lib/jt65_decode.f90, lib/decoder.f90).
- Revisit the single-pass `do` workaround in lib/decoder.f90 if the gfortran block-construct bug is fixed.
