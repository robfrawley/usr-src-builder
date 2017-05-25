#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export RT_COMMANDS_RET=0
export RT_COMMANDS_ACT=()
export RT_COMMANDS_ACT_FB=()
export RT_COMMANDS_INC=false

for e in "${RT_INCS[@]}"
do
    RT_COMMANDS_ACT+=("${BIN_PHPENV} conf add ${RT_PATH}/${e}.ini")
    RT_COMMANDS_ACT+=("${BIN_PHPENV} conf enable ${e}")
done

RT_COMMANDS_ACT+=("${BIN_PHPENV} rehash")

writeSourcedFile "${RT_PATH}/_php-configuration-runner.bash"
. "${RT_PATH}/_php-configuration-runner.bash"

# EOF #
