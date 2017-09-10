#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RUN_ACTION_INDEX=-1
RUN_ACTION_COUNT=-1
RUN_CMD_WORKING_PATH=false

if [[ ${BLD_MODE_DESC} == false ]]; then
    BLD_MODE_DESC="${BLD_MODE}"
fi

if [[ "${BLD_MODE_DESC_HIDE:-x}" != "true" ]]; then
    writeEnvironmentEnter "${BLD_MODE_DESC}"
fi

for c in "${BLD_INCS[@]}"
do
    if [[ ${BLD_MODE_APPEND} == false ]]; then
        BLD_ACT="${c}"
    else
        BLD_ACT="${BLD_MODE}-${c}"
    fi

    RUN_ACTION_INDEX=$(((${RUN_ACTION_INDEX} + 1)))
    RUN_ACTION_RETURN_LAST=0
    RUN_ACTION_RETURN_GLOB=0
    RUN_ACTION_SOURCE_INST="$(readlink -m ${BLD_PATH}/${BLD_ACT}.bash)"
    RUN_ACTION_SOURCE_LOGS=$(getReadyTempFilePath ${LOG_ENV}${BLD_ACT//[^A-Za-z0-9._-]/_}.log)

    LOG_ALL+=("${RUN_ACTION_SOURCE_LOGS}")

    if [[ ${BLD_COMMANDS_INC} != false ]]; then
        RUN_ACTION_INSTRUCTIONS_CMD=false
        RUN_ACTION_INSTRUCTIONS_SQL=false
        RUN_ACTION_INSTRUCTIONS_EXE=false
        writeActionSourcedFile "${RUN_ACTION_SOURCE_INST}"
        . ${RUN_ACTION_SOURCE_INST}
    fi

    if [[ ${RUN_ACTION_INSTRUCTIONS_CMD} == false ]] && [[ ${RUN_ACTION_INSTRUCTIONS_SQL} == false ]] && [[ ${RUN_ACTION_INSTRUCTIONS_EXE} == false ]]; then
        writeWarning "No operation commands defined in ${RUN_ACTION_SOURCE_INST}"
        continue
    fi

    MOD_ENV_MAKE_BLD="${BLD_EXT}/$(date +%s.%N)"
    MOD_ENV_MAKE_BLD=$(getReadyTempPath ${MOD_ENV_MAKE_BLD})

    if [[ ${RUN_CMD_WORKING_PATH} != false ]]; then
        writeExecuted "cd ${MOD_ENV_MAKE_BLD}"
        cd ${MOD_ENV_MAKE_BLD}
    fi

    if [[ ${RUN_ACTION_INSTRUCTIONS_CMD} != false ]] && [[ ${#RUN_ACTION_INSTRUCTIONS_CMD[@]} -gt 0 ]]; then
        writeDebug "$(printf 'Running %d commands (mode: cmd)' ${#RUN_ACTION_INSTRUCTIONS_CMD[@]})"
        writeDebugSourcedFile "${BLDR_COMMON_PATH_NAME}/command-set_run-cmd.bash"
        . "${BLDR_COMMON_PATH_NAME}/command-set_run-cmd.bash"
    else
        writeDebug "Action instructions for commands are empty."
    fi

    if [[ ${RUN_ACTION_INSTRUCTIONS_SQL} != false ]] && [[ ${#RUN_ACTION_INSTRUCTIONS_SQL[@]} -gt 0 ]]; then
        writeDebug "$(printf 'Running %d commands (mode: sql)' ${#RUN_ACTION_INSTRUCTIONS_SQL[@]})"
        writeDebugSourcedFile "${BLDR_COMMON_PATH_NAME}/command-set_run-sql.bash"
        . "${BLDR_COMMON_PATH_NAME}/command-set_run-sql.bash"
    else
        writeDebug "Action sql statements for commands are empty."
    fi

    if [[ ${RUN_ACTION_INSTRUCTIONS_EXE} != false ]] && [[ ${#RUN_ACTION_INSTRUCTIONS_EXE[@]} -gt 0 ]]; then
        writeDebug "$(printf 'Running %d script files (mode: exe)' ${#RUN_ACTION_INSTRUCTIONS_EXE[@]})"
        writeDebugSourcedFile "${BLDR_COMMON_PATH_NAME}/command-set_run-exe.bash"
        . "${BLDR_COMMON_PATH_NAME}/command-set_run-exe.bash"
    else
        writeDebug "Action instructions for executable are empty."
    fi
done

if [[ ${RUN_ACTION_COUNT} == 0 ]] && [[ "${B_VERBOSE}" -eq 1 ]]; then
    writeWarning "$(printf 'No commands executed for "%s:%s[%s]" context' ${ACTION_CONTEXT} ${ACTION_TYPE} "${BLD_MODE_DESC,,}")"
fi

if [[ "${BLD_MODE_DESC_HIDE:-x}" != "true" ]]; then
    writeEnvironmentExit "${BLD_MODE_DESC}"
fi

export BLD_MODE_APPEND=false
export BLD_MODE=""
export BLD_MODE_DESC=false
export BLD_INCS=()
export BLD_PATH=""
export RUN_ACTION_RETURN_GLOB=0
export RUN_ACTION_INSTRUCTIONS_CMD=()
export RUN_ACTION_INSTRUCTIONS_CMD_FALLBACK=()
export RUN_ACTION_INSTRUCTIONS_SQL=()
export RUN_ACTION_INSTRUCTIONS_EXE=()
export BLD_COMMANDS_INC=true
export RUN_ACTION_SQLS=()
export BLD_MODE_DESC_HIDE=false
