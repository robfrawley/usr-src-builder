#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _BLD_ALL=()
export _BLD_DIR="$(getReadyTempPath "${_TMP_DIR}/bldr/work")"
export _BLD_GEN="$(getReadyTempPath "${_BLD_DIR}")"
export _BLD_EXT="$(getReadyTempPath "${_BLD_DIR}/php-extensions")"
export _BLD_APP="$(getReadyTempPath "${_BLD_DIR}/application")"
export _BLD_ENV="$(getReadyTempPath "${_BLD_DIR}/environment")"
