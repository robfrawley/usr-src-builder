#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export RT_COMMANDS_RET=0
export RT_COMMANDS_ACT=()
export RT_COMMANDS_ACT_FB=()

opStart "Running \"${RT_MODE_DESC^^}\" external operations."

for e in "${RT_INCS[@]}"
do
	opSource "${RT_PATH}/_php-extensions-runner.bash"
	export MOD_NAME=${e}
	. "${RT_PATH}/_php-extensions-runner.bash"
done

opDone "Running \"${RT_MODE_DESC^^}\" external operations."

# EOF #
