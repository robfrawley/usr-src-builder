#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_BLD_MODE_THIS_DESC="${_BLD_MODE}"

if [[ ${_BLD_MODE_DESC} != false ]]; then
    _BLD_MODE_THIS_DESC="${_BLD_MODE_DESC}"
fi

writeEnvironmentEnter "${_BLD_MODE_DESC}"

for c in "${_BLD_INCS[@]}"; do
    _RUN_ACTION_INSTRUCTIONS_PHP_INC="${c}"
    writeActionSourcedFile "${_BLD_PATH}/_php-configuration-add.bash" "${c}"
    . "${_BLD_PATH}/_php-configuration-add.bash"
done

if [[ ${_BLD_MODE_DESC} == false ]]; then
    _BLD_MODE_DESC="${_BLD_MODE}"
fi

writeEnvironmentExit "${_BLD_MODE_THIS_DESC}"
