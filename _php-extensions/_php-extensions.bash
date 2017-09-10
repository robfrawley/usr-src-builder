#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

if [[ ${BLD_MODE_DESC} == false ]]; then
    BLD_MODE_DESC="${BLD_MODE}"
fi

writeEnvironmentEnter "${BLD_MODE_DESC}"

for e in "${BLD_INCS[@]}"; do
    RUN_ACTION_INSTRUCTIONS_PHP_EXT="${e}"
	writeActionSourcedFile "${BLD_PATH}/_php-extensions-add.bash" "${e}"
    . "${BLD_PATH}/_php-extensions-add.bash"
done

writeEnvironmentExit "${BLD_MODE_DESC}"
