#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

for exe in "${_RUN_ACTION_INSTRUCTIONS_EXE[@]}"; do
    _RUN_ACTION_COUNT=$(((${_RUN_ACTION_COUNT} + 1)))
    _RUN_ACTION_RETURN_LAST=0

    doRunCmdExternal "${exe}" || _RUN_ACTION_RETURN_LAST=1

    if [[ ${_RUN_ACTION_RETURN_LAST} == 0 ]]; then
        continue;
    fi

    writeFailedLogOutput "${_RUN_ACTION_SOURCE_LOGS}" "${_BLD_MODE}:${c}"
    writeError "Exiting due to executable failures!"
done

