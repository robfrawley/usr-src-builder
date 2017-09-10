#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

BLD_MODE_THIS_DESC="${BLD_MODE}"

if [[ ${BLD_MODE_DESC} != false ]]; then
    BLD_MODE_THIS_DESC="${BLD_MODE_DESC}"
fi

writeEnvironmentEnter "${BLD_MODE_DESC}"

for c in "${BLD_INCS[@]}"; do
    RUN_ACTION_INSTRUCTIONS_PHP_INC="${c}"
    writeActionSourcedFile "${BLD_PATH}/_php-configuration-add.bash" "${c}"
    . "${BLD_PATH}/_php-configuration-add.bash"
done

if [[ ${BLD_MODE_DESC} == false ]]; then
    BLD_MODE_DESC="${BLD_MODE}"
fi

writeEnvironmentExit "${BLD_MODE_THIS_DESC}"
