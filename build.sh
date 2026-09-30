#!/usr/bin/env sh

sbcl \
  --eval '(ql:quickload :nhl)' \
  --eval '(sb-ext:save-lisp-and-die "nhl" :toplevel (function nhl:main) :executable t)'

