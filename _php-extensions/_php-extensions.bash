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

writeEnvironmentEnter "${BLD_MODE_DESC}"

for e in "${BLD_INCS[@]}"
do
	writeSourcedFile "${BLD_PATH}/_php-extensions-runner.bash"
	export MOD_NAME=${e}
	. "${BLD_PATH}/_php-extensions-runner.bash"
done

writeEnvironmentExit "${BLD_MODE_DESC}"

