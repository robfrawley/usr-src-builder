#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

if [ -z ${_BLD_OUT_VERY_QUIET+x} ]; then
    export _BLD_OUT_VERY_QUIET=0
fi

if [ -z ${_BLD_OUT_QUIET+x} ]; then
    export _BLD_OUT_QUIET=0
fi

if [ -z ${_BLD_OUT_VERBOSE+x} ]; then
    export _BLD_OUT_VERBOSE=0
fi

if [ -z ${_BLD_OUT_VERY_VERBOSE+x} ]; then
    export _BLD_OUT_VERY_VERBOSE=0
fi

if [ -z ${_BLD_OUT_DEBUG+x} ]; then
    export _BLD_OUT_DEBUG=0
fi
