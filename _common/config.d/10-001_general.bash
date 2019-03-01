#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _CMD_PRE=""
export _CMD_ENV=""
export _DIR_CWD="$(pwd)"
export _TMP_DIR="$(readlink -m "${_DIR_CWD}/var")"
