You are working on WSJT-X, a weak-signal communication software.

This project is built with CMake.  There is already a cmake build directory at
`../wsjtx-build`.  You can build the project with `cmake --build
../wsjtx-build`.  After changing Fortran code that could affect decoding, run
`tests/decoder_regression.sh` to check the decoder against recorded output.

The project is a mixture of Fortran and C++.  The C++ comprises a Qt GUI and
related connectivity code.  The Fortran code does signal processing and
interpretation.

When committing, please identify yourself as the model you are using `-c
user.name=... -c user.email=...` flags to Git.  For example,

`git -c user.name="DeepSeek R1" -c user.email=deepseek-r1@deepseek.com commit ...`

In commit messages, stick to high level goals.  It can sometimes be appropriate
to describe nontrivial design choices.  But it is inappropriate to itemize
changes that would be reasonably obvious by looking at the diff.

When writing code, take care not to introduce persistent artifacts in the code
(e.g. comments) that reference information that is only present within the
context of a single agent session.  For example, if you are implementing
something in several phases, a comment in the code saying "phase 2" is
inappropriate, as future readers will lack the context to understand what is
meant.

Take care also not to introduce historical context unless it is necessary.  For
example, if a variable changed name from "foo" to "bar", a comment saying "used
to be called foo" or similar is inappropriate.  Git records history after all.
