#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _LOG_ALL=()
export _LOG_BUF=()
export _LOG_DIR="$(getReadyTempPath "${_TMP_DIR}/bldr/logs")"
export _LOG_GEN="$(getReadyTempPath "${_LOG_DIR}")"
export _LOG_EXT="$(getReadyTempPath "${_LOG_DIR}/php-extensions")"
export _LOG_APP="$(getReadyTempPath "${_LOG_DIR}/application")"
export _LOG_ENV="$(getReadyTempPath "${_LOG_DIR}/environment")"
