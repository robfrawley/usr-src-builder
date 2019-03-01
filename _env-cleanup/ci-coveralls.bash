#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##+

_RUN_ACTION_INSTRUCTIONS_CMD=(
    "${_BIN_PHP} ${_BLD_COVERALLS_BIN_PATH} ${_BLD_COVERALLS_BIN_OPTS}"
)
