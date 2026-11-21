# Fortran Modernization TODO

Small, self-contained tasks. Do one per commit, keep the build green.

## Replace remaining `go to` flow control

- Replace `go to` in lib/packjt77.f90 (77bit/packjt77.f90).
- Replace `go to` in lib/packjt.f90.
- Replace `go to` in lib/decoder.f90.
- Replace `go to` in lib/options.f90.
- Replace `go to` in lib/q65_decode.f90.
- Replace `go to` in lib/jt65_decode.f90.
- Replace `go to` in lib/ft8_decode.f90.
- Replace `go to` in lib/ft4_decode.f90.
- Replace `go to` in lib/fst4_decode.f90.

## Turn `jt9com` consumers into modules with `implicit none`

- Turn lib/decode_msk144.f90 into a module with `implicit none`.
- Turn lib/symspec.f90 into a module with `implicit none`.
- Add `implicit none` to the jt9 program and declare implicit locals.
- Migrate the `common` blocks in lib/jt9.f90 to module variables.
