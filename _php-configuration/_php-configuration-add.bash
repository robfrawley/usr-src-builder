#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _RUN_ACTION_RETURN_GLOB=0
export _RUN_ACTION_INSTRUCTIONS_CMD=()
export _RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK=()
export _BLD_COMMANDS_INC=false
export _BLD_MODE_DESC_HIDE="true"

_RUN_ACTION_INSTRUCTIONS_CMD=(
    "${_BIN_PHPENV} config-add ${_BLD_PATH}/${_RUN_ACTION_INSTRUCTIONS_PHP_INC}.ini"
    "${_BIN_PHPENV} conf enable ${_RUN_ACTION_INSTRUCTIONS_PHP_INC}"
    "${_BIN_PHPENV} rehash"
)

_RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK=(
    "${_BIN_PHPENV} conf add ${_BLD_PATH}/${_RUN_ACTION_INSTRUCTIONS_PHP_INC}.ini"
    "continue"
    "continue"
)

writeDebugSourcedFile "${_BLD_PATH}/_php-configuration-runner.bash"
. "${_BLD_PATH}/_php-configuration-runner.bash"

