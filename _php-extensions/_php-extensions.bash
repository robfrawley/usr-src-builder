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

writeEnvironmentEnter "${RT_MODE_DESC}"

for e in "${RT_INCS[@]}"
do
	writeSourcedFile "${RT_PATH}/_php-extensions-runner.bash"
	export MOD_NAME=${e}
	. "${RT_PATH}/_php-extensions-runner.bash"
done

writeEnvironmentExit "${RT_MODE_DESC}"

# EOF #
