# Fortran Modernization TODO

Small, self-contained tasks. Do one per commit, keep the build green.

## Replace remaining `go to` flow control

- Replace `go to` in lib/options.f90.

## Add `implicit none` and declare implicit locals

- Add `implicit none` to module packjt and declare its implicit locals.
- Turn lib/mskrtd.f90 into a module with `implicit none` (and remove its `go to`s).
