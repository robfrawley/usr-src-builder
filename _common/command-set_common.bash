#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_RUN_ACTION_INDEX=-1
_RUN_ACTION_COUNT=-1
_RUN_CMD_WORKING_PATH=false

if [[ ${_BLD_MODE_DESC} == false ]]; then
    _BLD_MODE_DESC="${_BLD_MODE}"
fi

if [[ "${_BLD_MODE_DESC_HIDE:-x}" != "true" ]]; then
    writeEnvironmentEnter "${_BLD_MODE_DESC}"
fi

for c in "${_BLD_INCS[@]}"
do
    if [[ ${_BLD_MODE_APPEND} == false ]]; then
        _BLD_ACT="${c}"
    else
        _BLD_ACT="${_BLD_MODE}-${c}"
    fi

    _RUN_ACTION_INDEX=$(((${_RUN_ACTION_INDEX} + 1)))
    _RUN_ACTION_RETURN_LAST=0
    _RUN_ACTION_RETURN_GLOB=0
    _RUN_ACTION_SOURCE_INST="$(readlink -m ${_BLD_PATH}/${_BLD_ACT}.bash)"
    _RUN_ACTION_SOURCE_LOGS=$(getReadyTempFilePath ${_LOG_ENV}${_BLD_ACT//[^A-Za-z0-9._-]/_}.log)

    _LOG_ALL+=("${_RUN_ACTION_SOURCE_LOGS}")

    if [[ ${_BLD_COMMANDS_INC} != false ]]; then
        _RUN_ACTION_INSTRUCTIONS_CMD=false
        _RUN_ACTION_INSTRUCTIONS_SQL=false
        _RUN_ACTION_INSTRUCTIONS_EXE=false
        writeActionSourcedFile "${_RUN_ACTION_SOURCE_INST}"
        . ${_RUN_ACTION_SOURCE_INST}
    fi

    if [[ ${_RUN_ACTION_INSTRUCTIONS_CMD} == false ]] && [[ ${_RUN_ACTION_INSTRUCTIONS_SQL} == false ]] && [[ ${_RUN_ACTION_INSTRUCTIONS_EXE} == false ]]; then
        writeWarning "No operation commands defined in ${_RUN_ACTION_SOURCE_INST}"
        continue
    fi

    _MOD_ENV_MAKE_BLD="${_BLD_EXT}/$(date +%s.%N)"
    _MOD_ENV_MAKE_BLD=$(getReadyTempPath ${_MOD_ENV_MAKE_BLD})

    if [[ ${_RUN_CMD_WORKING_PATH} != false ]]; then
        writeExecuted "cd ${_MOD_ENV_MAKE_BLD}"
        cd ${_MOD_ENV_MAKE_BLD}
    fi

    if [[ ${_RUN_ACTION_INSTRUCTIONS_CMD} != false ]] && [[ ${#_RUN_ACTION_INSTRUCTIONS_CMD[@]} -gt 0 ]]; then
        writeDebug "$(printf 'Running %d commands (mode: cmd)' ${#_RUN_ACTION_INSTRUCTIONS_CMD[@]})"
        writeDebugSourcedFile "${_BLDR_COMMON_PATH_NAME}/command-set_run-cmd.bash"
        . "${_BLDR_COMMON_PATH_NAME}/command-set_run-cmd.bash"
    else
        writeDebug "Action instructions for commands are empty."
    fi

    if [[ ${_RUN_ACTION_INSTRUCTIONS_SQL} != false ]] && [[ ${#_RUN_ACTION_INSTRUCTIONS_SQL[@]} -gt 0 ]]; then
        writeDebug "$(printf 'Running %d commands (mode: sql)' ${#_RUN_ACTION_INSTRUCTIONS_SQL[@]})"
        writeDebugSourcedFile "${_BLDR_COMMON_PATH_NAME}/command-set_run-sql.bash"
        . "${_BLDR_COMMON_PATH_NAME}/command-set_run-sql.bash"
    else
        writeDebug "Action sql statements for commands are empty."
    fi

    if [[ ${_RUN_ACTION_INSTRUCTIONS_EXE} != false ]] && [[ ${#_RUN_ACTION_INSTRUCTIONS_EXE[@]} -gt 0 ]]; then
        writeDebug "$(printf 'Running %d script files (mode: exe)' ${#_RUN_ACTION_INSTRUCTIONS_EXE[@]})"
        writeDebugSourcedFile "${_BLDR_COMMON_PATH_NAME}/command-set_run-exe.bash"
        . "${_BLDR_COMMON_PATH_NAME}/command-set_run-exe.bash"
    else
        writeDebug "Action instructions for executable are empty."
    fi
done

if [[ ${_RUN_ACTION_COUNT} == 0 ]] && [[ "${_BLD_OUT_VERBOSE}" -eq 1 ]]; then
    writeWarning "$(printf 'No commands executed for "%s:%s[%s]" context' ${_ACTION_CONTEXT} ${_ACTION_TYPE} "${_BLD_MODE_DESC,,}")"
fi

if [[ "${_BLD_MODE_DESC_HIDE:-x}" != "true" ]]; then
    writeEnvironmentExit "${_BLD_MODE_DESC}"
fi

export _BLD_MODE_APPEND=false
export _BLD_MODE=""
export _BLD_MODE_DESC=false
export _BLD_INCS=()
export _BLD_PATH=""
export _RUN_ACTION_RETURN_GLOB=0
export _RUN_ACTION_INSTRUCTIONS_CMD=()
export _RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK=()
export _RUN_ACTION_INSTRUCTIONS_SQL=()
export _RUN_ACTION_INSTRUCTIONS_EXE=()
export _BLD_COMMANDS_INC=true
export _RUN_ACTION_SQLS=()
export _BLD_MODE_DESC_HIDE=false
