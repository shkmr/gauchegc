#!/bin/sh
#| -*- mode: scheme; coding: utf-8; -*-
DEBUG=""
[ "x$1" = "x-v" ] && DEBUG="-uprofile"
if [ "x$1" = "x-vv" ]; then
DEBUG="-uprofile"
DEBUG_VERBOSE_GLOBAL=1
export DEBUG_VERBOSE_GLOBAL
fi        
# |#
:; exec gosh -I. $DEBUG -- $0 "$@"

;; uh :-(
(when (sys-getenv "DEBUG_VERBOSE_GLOBAL")
  (profile-global-hack))

(use foo)
(use bar)

(define (test)
  #?=(+ 2 3)
  #?=(foo-proc)
  #?=(bar-proc "k" "l")
  (guard (e [else #f])
         #?=(bar-error-proc)))

(define (main args)
  #?=(test)
  0)