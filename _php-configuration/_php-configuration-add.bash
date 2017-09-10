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
export BLD_COMMANDS_INC=false
export BLD_MODE_DESC_HIDE="true"

RUN_ACTION_INSTRUCTIONS_CMD=(
    "${BIN_PHPENV} conf add ${BLD_PATH}/${RUN_ACTION_INSTRUCTIONS_PHP_INC}.ini"
    "${BIN_PHPENV} conf enable ${RUN_ACTION_INSTRUCTIONS_PHP_INC}"
    "${BIN_PHPENV} rehash"
)

RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK=(
    "${BIN_PHPENV} config-add ${BLD_PATH}/${RUN_ACTION_INSTRUCTIONS_PHP_INC}.ini"
    ""
    "${BIN_PHPENV} rehash"
)

writeDebugSourcedFile "${BLD_PATH}/_php-configuration-runner.bash"
. "${BLD_PATH}/_php-configuration-runner.bash"

