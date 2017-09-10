#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export RUN_ACTION_RETURN_GLOB=0
export RUN_ACTION_INSTRUCTIONS_CMD=()
export RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK=()

export MOD_NAME="${RUN_ACTION_INSTRUCTIONS_PHP_EXT}"
. "${BLD_PATH}/_php-extensions-runner.bash"
