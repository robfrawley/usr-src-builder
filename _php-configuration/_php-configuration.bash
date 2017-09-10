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

for e in "${BLD_INCS[@]}"
do
    RUN_ACTION_INSTRUCTIONS_CMD+=("${BIN_PHPENV} conf add ${BLD_PATH}/${e}.ini")
    RUN_ACTION_INSTRUCTIONS_CMD+=("${BIN_PHPENV} conf enable ${e}")
done

RUN_ACTION_INSTRUCTIONS_CMD+=("${BIN_PHPENV} rehash")

writeDebugSourcedFile "${BLD_PATH}/_php-configuration-runner.bash"
. "${BLD_PATH}/_php-configuration-runner.bash"

