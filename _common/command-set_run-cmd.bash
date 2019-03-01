#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_RUN_ACTION_COUNT=-1

for cmd in "${_RUN_ACTION_INSTRUCTIONS_CMD[@]}"
do
    _RUN_ACTION_COUNT=$(((${_RUN_ACTION_COUNT} + 1)))

    _RUN_ACTION_RETURN_LAST=0
    doRunCmdInline "${cmd}" || _RUN_ACTION_RETURN_LAST=$?

    if [[ ${_RUN_ACTION_RETURN_LAST} == 0 ]]; then
        continue;
    fi

    if [ ${_RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK[$_RUN_ACTION_COUNT]+x} ]; then
        if [[ "${_RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK[$_RUN_ACTION_COUNT]}" == "continue" ]]; then
            writeSmallWarning "Command configured to continue on failure..."
            continue;
        fi

        writeSmallWarning "Command fallback will be attempted..."

        _RUN_ACTION_RETURN_LAST=0
        doRunCmdInline "${_RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK[$_RUN_ACTION_COUNT]}" || _RUN_ACTION_RETURN_LAST=$?
    fi

    if [[ ${_RUN_ACTION_RETURN_LAST} == 0 ]]; then
        continue;
    fi

    writeFailedLogOutput "${_RUN_ACTION_SOURCE_LOGS}" "${_BLD_MODE}:${cmd}"
    writeError "Exiting due to command failures!"
done

