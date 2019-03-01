#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _BLD_MODE_APPEND=false
export _BLD_MODE=""
export _BLD_MODE_DESC=false
export _BLD_INCS=()
export _BLD_PATH=""
export _RUN_ACTION_RETURN_GLOB=0
export _RUN_ACTION_INSTRUCTIONS_CMD=()
export _RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK=()
export _RUN_ACTION_INSTRUCTIONS_SQL=()
export _RUN_ACTION_INSTRUCTIONS_EXE=()
export _BLD_COMMANDS_INC=true
export _BLD_TMP_PRESERVE=false
