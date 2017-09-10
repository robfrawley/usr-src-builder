#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RUN_ACTION_COUNT=-1

for cmd in "${RUN_ACTION_INSTRUCTIONS_CMD[@]}"
do
    RUN_ACTION_COUNT=$(((${RUN_ACTION_COUNT} + 1)))

    RUN_ACTION_RETURN_LAST=0
    doRunCmdInline "${cmd}" || RUN_ACTION_RETURN_LAST=$?

    if [[ ${RUN_ACTION_RETURN_LAST} == 0 ]]; then
        continue;
    fi

    if [ ${RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK[$RUN_ACTION_COUNT]+x} ]; then
        if [[ "${RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK[$RUN_ACTION_COUNT]}" == "continue" ]]; then
            writeSmallWarning "Command configured to continue on failure..."
            continue;
        fi

        writeSmallWarning "Command fallback will be attempted..."

        RUN_ACTION_RETURN_LAST=0
        doRunCmdInline "${RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK[$RUN_ACTION_COUNT]}" || RUN_ACTION_RETURN_LAST=$?
    fi

    if [[ ${RUN_ACTION_RETURN_LAST} == 0 ]]; then
        continue;
    fi

    writeFailedLogOutput "${RUN_ACTION_SOURCE_LOGS}" "${BLD_MODE}:${cmd}"
    writeError "Exiting due to command failures!"
done

