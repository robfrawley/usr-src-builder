#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

for exe in "${RUN_ACTION_INSTRUCTIONS_EXE[@]}"; do
    RUN_ACTION_COUNT=$(((${RUN_ACTION_COUNT} + 1)))
    RUN_ACTION_RETURN_LAST=0

    doRunCmdExternal "${exe}" || RUN_ACTION_RETURN_LAST=1

    if [[ ${RUN_ACTION_RETURN_LAST} == 0 ]]; then
        continue;
    fi

    writeFailedLogOutput "${RUN_ACTION_SOURCE_LOGS}" "${BLD_MODE}:${c}"
    writeError "Exiting due to executable failures!"
done

