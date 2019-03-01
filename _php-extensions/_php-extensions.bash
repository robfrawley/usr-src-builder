#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

if [[ ${_BLD_MODE_DESC} == false ]]; then
    _BLD_MODE_DESC="${_BLD_MODE}"
fi

writeEnvironmentEnter "${_BLD_MODE_DESC}"

for e in "${_BLD_INCS[@]}"; do
    _RUN_ACTION_INSTRUCTIONS_PHP_EXT="${e}"
	writeActionSourcedFile "${_BLD_PATH}/_php-extensions-add.bash" "${e}"
    . "${_BLD_PATH}/_php-extensions-add.bash"
done

writeEnvironmentExit "${_BLD_MODE_DESC}"
