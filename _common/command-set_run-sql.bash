#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

for statement in "${_RUN_ACTION_INSTRUCTIONS_SQL[@]}"; do
    _RUN_ACTION_COUNT=$(((${_RUN_ACTION_COUNT} + 1)))
    _RUN_ACTION_RETURN_LAST=0

    doRunSqlStatement "${statement}" || _RUN_ACTION_RETURN_LAST=1

    if [[ ${_RUN_ACTION_RETURN_LAST} == 0 ]]; then
        continue;
    fi

    writeFailedLogOutput "${_RUN_ACTION_SOURCE_LOGS}" "${_BLD_MODE}:${c}"
    writeError "Exiting due to sql statement failures!"
done

