#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

function colorAssign()
{
    if [[ -n ${1} ]] && [[ ${1} != false ]]; then CLR_PRE="${1}"; fi
    if [[ -n ${2} ]] && [[ ${1} != false ]]; then CLR_HDR="${2}"; fi
    if [[ -n ${3} ]] && [[ ${1} != false ]]; then CLR_TXT="${3}"; fi
}

function colorReset()
{
    CLR_TXT=""
    CLR_PRE=""
    CLR_HDR=""
}

function writeNewLine()
{
    echo -en "\n"
}

function writeLines()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"

    shift

    local len=0
    local ind=true
    local i=0

    if [[ ${OUT_PRE_LINE} == true ]]
    then
        writePrefix "${p}"
    fi

    for l in ${@:-}
    do
        tmp="${l/#$DIR_CWD/.}"
        if [[ "$(echo $tmp | wc -m)" != "$((($(echo $l | wc -m) + 1)))" ]]
        then
            l="${tmp}"
        fi

        len=$((($(echo "${l}" | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | wc -m) + $len + 1)))

        if [[ ${len} -gt ${OUT_MAX_CHAR} ]]
        then
            len=$(echo "${l}" | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | wc -m)
            ind=true
            writeNewLine
            if [[ ${OUT_PRE_LINE} == true ]]
            then
                writePrefix "${p}"
            fi
        fi

        if [[ ${OUT_PRE_LINE} != true ]]
        then
            OUT_PRE_LINE=true
        fi

        if [[ ${i} == 0 ]]
        then
            SEQ=${OUT_SPACE_F}
        else
            SEQ=${OUT_SPACE_N}
        fi

        if [[ $len == 0 ]] || [[ $ind == true ]]
        then
            for i in $(seq 1 ${SEQ})
            do
                l=" $l"
            done

            ind=false
            len=$((($length + 1)))
        fi

        echo -en "${CLR_RST}${CLR_TXT_D}${CLR_TXT}${l}${CLR_RST} "

        i=$(((${i} + 1)))
    done

    if [[ ${OUT_NEW_LINE} == true ]]
    then
        writeNewLine
        OUT_NEW_LINE=true
    else
        OUT_NEW_LINE=true
    fi

    OUT_SPACE_F=1
    OUT_SPACE_N=1
    OUT_PRE_LINE=true
}

function writeTitle()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local l="${2:-BLOCK}"
    local s="${3:-true}"

    if [[ $s == true ]]
    then
        writePrefix ${p} true
        writeLines ${p} "${CLR_HDR_D}${CLR_HDR}${l}${CLR_RST}"
    else
        writeLines ${p} "${CLR_HDR_D}${CLR_HDR}${l}${CLR_RST}"
    fi

    if [[ $s == true ]]; then writePrefix ${p} true; fi
}

function writePrefix()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    if [[ ${3} != true ]]; then echo -en "  "; fi

    echo -en "${CLR_PRE_D}${CLR_PRE}${1}${CLR_RST}"

    if [[ ${2} == true ]]; then writeNewLine; fi
}

function writeBlockLarge()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    writeTitle  ${p} ${t}
    writeLines  ${p} ${l[@]}
    writePrefix ${p} true
}

function writeBlockSmall()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    OUT_NEW_LINE=false
    writeTitle ${p} "${t}" false
    OUT_PRE_LINE=false
    OUT_SPACE_F=0
    writeLines ${p} ${l[@]}
}

function writeBlock()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    writeTitle ${p} "${t}" false
    writeLines ${p} ${l[@]}
}

function writeSequence()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local i=${1:-3}
    local s="${2:--}"
    local c="${3:-false}"

    for seq in $(seq 1 ${i})
    do
        echo -en "${CLR_TXT_D}${CLR_TXT}"

        if [[ ${c} != false ]]
        then
            echo -en "${3}"
        fi

        echo -en "${s}${CLR_RST}"
    done

    colorReset
}

function writeFailedLogOutput()
{
    local file="${1}"
    local task="${2}"
    local size=$(wc -l < "${file}")

    if [[ "${B_QUIET}" -eq 1 ]]; then
        colorAssign "${CLR_L_RED}" "${CLR_B_RED}" "${CLR_L_WHITE}"
        writeBlockLarge "##" "CRIT" "Failed command log output: ${file}"

        return
    fi

    if [[ ! -f "${file}" ]] || [[ ! $size -gt 0 ]]; then
        writeWarning "Failed command did not produce any output logs to display!"
        removeFile "${file}"

        return
    fi

    lines_pluralized="lines"
    if [[ ${size} == 1 ]]; then
        lines_pluralized="line"
    fi

    writeSmallWarning "$(printf 'Command output logged %d %s to file: %s' ${size} ${lines_pluralized} "${file}")"

    echo -en "  ${CLR_L_YELLOW}++-- ${CLR_B_YELLOW}LOG DUMP START${CLR_L_YELLOW} [ ${task} ] --++${CLR_RST}" && writeNewLine && writeNewLine
    cat ${file} | sed '/^\s*$/d'
    writeNewLine && echo -en "  ${CLR_L_YELLOW}++-- ${CLR_B_YELLOW}LOG DUMP END  ${CLR_L_YELLOW} [ ${task} ] --++${CLR_RST}" && writeNewLine

    removeFile "${file}"
}

function removeFile()
{
    local file="${1}"
    local allow_preserve="${2:-true}"

    if [[ ! ${file} ]]; then
        return
    fi

    if [[ ${allow_preserve} == "true" ]] && [[ "${BLD_TMP_PRESERVE}" == "true" ]]; then
        writeDebug "Preserving temporary file: ${file}"
        return
    fi

    writeDebug "Removing temporary file: ${file}"
    rm -fr "${file}"
}

function appendLogBufferLines()
{
    LOG_BUF+=("${@}")
}

function flushLogBufferLines()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        LOG_BUF=()
        return
    fi

    local t="${1:-MAKE}"
    local p="${2:-==}"

    if [[ ${#LOG_BUF[@]} -lt 1 ]]
    then
        writeWarning "No log build lines to flush."
    fi

    for l in "${LOG_BUF[@]}"
    do
        colorAssign "${CLR_L_BLUE}" "${CLR_L_BLUE}"

        OUT_NEW_LINE=false
        writeTitle ${p} ${t} false

        OUT_PRE_LINE=false && OUT_SPACE_F=0 && OUT_SPACE_N=5
        writeLines ${p} "${l[@]}"
    done

    colorReset
    writeNewLine
}

function writeEnter()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorAssign "${CLR_L_GREEN}" "${CLR_L_GREEN}" "${CLR_L_WHITE}"
    writeBlockSmall ">>" "INIT" "${@}"
    colorReset
}

function writeEnvironmentEnter()
{
    if [[ "${B_VERBOSE}" -eq 1 ]]; then
        colorAssign "${CLR_L_GREEN}" "${CLR_L_GREEN}" "${CLR_L_WHITE}"
        writeBlockSmall ">>" "INIT" "$(printf '[%s]' "${1,,}")"
        colorReset
    fi
}

function writeSectionEnter()
{
    if [[ "${B_VERY_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorAssign "${CLR_B_WHITE}" "${CLR_B_WHITE}" "${CLR_B_WHITE}"
    writeBlockSmall "->" "INIT" "${@}"
    colorReset
}

function writeExit()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorAssign "${CLR_L_GREEN}" "${CLR_L_GREEN}" "${CLR_L_WHITE}"
    writeBlockSmall "<<" "DONE" "${@}"
    colorReset
}

function writeEnvironmentExit()
{
    if [[ "${B_VERY_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorAssign "${CLR_L_GREEN}" "${CLR_L_GREEN}" "${CLR_L_WHITE}"
    writeBlockSmall "<<" "DONE" "$(printf '[%s]' "${1,,}")"
    colorReset
}

function writeSectionExit()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorAssign "${CLR_B_WHITE}" "${CLR_B_WHITE}" "${CLR_B_WHITE}"
    writeBlockSmall "<-" "DONE" "${@}"
    colorReset
}

function writeCritical()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorAssign "${CLR_L_RED}" "${CLR_L_RED}" "${CLR_L_RED}"
    writeBlock "##" "FAIL" "${@}"
    colorReset
}

function writeSectionCritical()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorAssign "${CLR_WHITE}" "${CLR_L_WHITE}" "${CLR_WHITE}"
    writeBlockSmall "##" "FAIL" "${@}"
    colorReset
}

function writeExecuted()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorAssign "${CLR_L_PURPLE}" "${CLR_L_PURPLE}"
    writeBlockSmall "++" "EXEC" "${@}"
    colorReset
}

function writeAndExecute()
{
    local command_bin="${1}"
    local write_action="${2:-true}"
    local command_ret=0

    if [[ "${write_action}" == "true" ]]; then
        writeExecuted "${command_bin}"
    fi

    ${command_bin} &>> ${RUN_ACTION_SOURCE_LOGS} || command_ret=$?

    return ${command_ret}
}

function doRunCmdInline()
{
    local cmd_bin="${1}"
    local cmd_ret=0

    if [[ "${cmd}" == "" ]]; then
        writeDebug "$(printf 'No command defined in index "%d" for "%s:%s[%s]" context: %s' ${RUN_ACTION_COUNT} ${ACTION_CONTEXT} ${ACTION_TYPE} "${BLD_MODE_DESC,,}" "${RUN_ACTION_SOURCE_INST:-null}")"
        return
    fi

    writeAndExecute "${cmd_bin}" || cmd_ret=$?

    if [[ ${cmd_ret} -ne 0 ]]; then
        writeSmallWarning "$(printf 'Command execution failed with return code %d...' ${cmd_ret})"
    fi

    return ${cmd_ret}
}

function doRunCmdExternal()
{
    local exe="${1}"

    if [[ "${exe}" == "" ]]; then
        writeWarning "$(printf 'No executable defined in index "%d" for "%s:%s[%s]" context: %s' ${RUN_ACTION_COUNT:-x} ${ACTION_CONTEXT:-x} ${ACTION_TYPE:-x} "${BLD_MODE_DESC,,:-x}" "${RUN_ACTION_SOURCE_INST:-x}")"
        return
    fi

    local command_ret=0
    local command_content=(
        "${exe}"
    )

    doRunCmdUsingTemporaryFile "${exe}" "${command_content[@]}" || command_ret=$?

    if [[ ${command_ret} -ne 0 ]]; then
        writeSmallWarning "$(printf 'Command execution failed with return code %d...' ${command_ret})"
    fi

    return ${command_ret}
}

function doRunSqlStatement()
{
    local statement="${1}"
    local db_user="${2:-x}"
    local db_pass="${3:-x}"
    local db_user="${4:-x}"

    if [[ "${statement}" == "" ]]; then
        writeWarning "$(printf 'No sql statement defined in index "%d" for "%s:%s[%s]" context: %s' ${RUN_ACTION_COUNT:-x} ${ACTION_CONTEXT:-x} ${ACTION_TYPE:-x} "${BLD_MODE_DESC,,:-x}" "${RUN_ACTION_SOURCE_INST:-x}")"
        return
    fi

    if [[ "${db_user}" == "x" ]]; then
        db_user="${BLD_DB_USER}"
    fi

    if [[ "${db_pass}" == "x" ]]; then
        db_pass="${BLD_DB_PASS}"
    fi

    if [[ "${db_name}" == "x" ]]; then
        db_name="${BLD_DB_NAME}"
    fi

    local command_ret=0
    local command_bin="$(which mysql) -u${BLD_DB_USER}"

    if [[ "${BLD_DB_PASS}" != "" ]]; then
        command_bin="${command_bin} -p\"${BLD_DB_PASS}\""
    fi

    if [[ "${BLD_DB_NAME}" != "" ]]; then
        command_bin="${command_bin} ${BLD_DB_NAME}"
    fi

    command_bin="${command_bin} -e \"${statement}\""

    local command_ret=0
    local command_content=(
        "${command_bin}"
    )

    doRunCmdUsingTemporaryFile "${command_bin}" "${command_content[@]}" || command_ret=$?

    if [[ ${command_ret} -ne 0 ]]; then
        writeSmallWarning "$(printf 'Sql statement execution failed with return code %d...' ${command_ret})"
    fi

    return ${command_ret}
}

function doRunCmdUsingTemporaryFile()
{
    local whats="${1}"
    shift
    local lines=("${@}")
    local command_ret=0
    local command_md5="$(echo "${lines[@]}" | md5sum | grep -oE '[a-z0-9]+')"
    local command_tmp="/tmp/bldr-run-${command_md5}.bash"
    local command_bin="$(which bash) ${command_tmp}"

    echo "#!/bin/sh" > "${command_tmp}"
    echo "" >> "${command_tmp}"
    echo "#" >> "${command_tmp}"
    echo "# builder temporary script" >> "${command_tmp}"
    echo "# $(printf '%s:%s:%s' ${ACTION_CONTEXT:-x} ${ACTION_TYPE:-x} "${BLD_MODE_DESC,,}")" >> "${command_tmp}"
    echo "#" >> "${command_tmp}"
    echo "" >> "${command_tmp}"
    echo "cd ${BLDR_PATH_NAME}/.. || exit \$?" >> "${command_tmp}"
    for l in "${lines[@]}"; do
        echo "${l} || exit \$?" >> "${command_tmp}"
    done

    writeDebug "Using temporary file to run action: ${command_tmp}"

    writeExecuted "${whats}"
    writeAndExecute "${command_bin}" "false" || command_ret=$?

    removeFile "${command_tmp}"

    return ${command_ret}
}

function writeSourcedFile()
{
    colorAssign "${CLR_YELLOW}" "${CLR_YELLOW}"
    writeBlockSmall "--" "FILE" "${@}"
    colorReset
}

function writeActionSourcedFile()
{
    local file="${1}"
    local more="${2:-x}"
    local text=""

    if [[ "${more}" == "x" ]]; then
        text="${file}"
    else
        text="${file} (${more})"
    fi

    colorAssign "${CLR_YELLOW}" "${CLR_B_YELLOW}" "${CLR_B_WHITE}"
    writeBlockSmall "==" "FILE" "${text}"
    colorReset
}

function writeDebugSourcedFile()
{
    if [[ "${B_VERY_VERBOSE}" -eq 1 ]]; then
        colorAssign "${CLR_YELLOW}" "${CLR_YELLOW}"
        writeBlockSmall "--" "FILE" "${@}"
        colorReset
    fi
}

function writeInfo()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorAssign "${CLR_YELLOW}" "${CLR_YELLOW}"
    writeBlockSmall "--" "INFO" "${@}"
    colorReset
}

function writeDebug()
{
    if [[ "${B_DEBUG}" -ne 1 ]]; then
        return
    fi

    colorAssign "${CLR_L_WHITE}" "${CLR_B_WHITE}"
    writeBlockSmall "<>" "DEBUG" "${@}"
    colorReset
}

function writeWarning()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorAssign "${CLR_L_RED}" "${CLR_L_RED}"

    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        writeBlockSmall "!!" "WARN" "${@}"
    else
        writeBlockLarge "!!" "WARN" "${@}"
    fi

    colorReset
}

function writeSmallWarning()
{
    local message="${1,,}"
    local state_b_verbose=${B_VERBOSE}

    B_VERBOSE=0
    writeWarning "${message}"
    B_VERBOSE=${state_b_verbose}
}

function writeError()
{
    if [[ "${B_VERY_QUIET}" -ne 1 ]]; then
        colorAssign "${CLR_L_RED}" "${CLR_B_RED}" "${CLR_L_WHITE}"
        writeBlockLarge "##" "CRIT" "${@}"
        colorReset
    fi

    exit -1
}

function writeComplete()
{
    if [[ "${B_DEBUG}" -eq 1 ]]; then
        colorAssign "${CLR_L_WHITE}" "${CLR_L_WHITE}" "${CLR_L_WHITE}"
        writeBlock "--" "EXITING" "${@}"
        colorReset
    fi
}

function writeDefinitionListing()
{
    if [[ "${B_DEBUG}" -ne 1 ]]; then
        return
    fi

    local lines=("$@")
    local iterations=${#lines[@]}
    local leftMaxLength=0
    local iterationRemainder=0
    local prefix="-- "

    for i in $(seq 0 1 $(((${iterations} - 1))))
    do
        line="${lines[${i}]}"
        value="${lines[$(((${i} + 1)))]}"

        if [[ "${line:0:1}" == ":" ]] || [[ "${line}" == "_" ]]
        then
            iterationRemainder=$(inverseBoolValueAsInt ${iterationRemainder})
            continue
        fi

        if [[ $(((${i} % 2))) != ${iterationRemainder} ]]
        then
            continue
        fi

        wc=$(echo -n "${line}" | wc -m)
        [[ ${wc} -gt ${leftMaxLength} ]] && leftMaxLength=${wc}
    done

    iterationRemainder=0
    leftMaxLength=$(((${leftMaxLength} + 3)))
    CLR_PRE=${CLR_WHITE}

    echo -e "  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}"

    for i in $(seq 0 1 $(((${iterations} - 1))))
    do
        line="${lines[${i}]}"
        value="${lines[$(((${i} + 1)))]}"

        if [[ "${line:0:1}" == ":" ]]
        then
            title="${line:1}"
            titleSurround=""
            iterationRemainder=$(inverseBoolValueAsInt ${iterationRemainder})

            for j in $(seq $(echo -n ${title} | wc -m))
            do
                titleSurround="${titleSurround}-"
            done

            [[ $i != 0 ]] && echo -e "  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}\n  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}"
            echo -e "  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}${CLR_WHITE}${title^^}${CLR_RST}"
            echo -e "  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}"

            continue
        fi

        if [[ "${line}" == "_" ]]
        then
            iterationRemainder=$(inverseBoolValueAsInt ${iterationRemainder})

            echo -e "  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}"
            continue
        fi

        if [[ $(((${i} % 2))) != ${iterationRemainder} ]]
        then
            continue
        fi

        dotCount=$(((${leftMaxLength} - $(echo ${line} | wc -m) + 2)))

        echo -en "  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}"
        echo -en "${CLR_RST}${CLR_TXT_D}${CLR_TXT}"
        echo -en "${line} "
        for i in $(seq 1 ${dotCount})
        do
            echo -en "${CLR_B_BLACK}.${CLR_RST}"
        done
        echo -e " ${CLR_L_WHITE}${value/#$DIR_CWD\//}${CLR_RST}"
    done

    echo -e "  ${CLR_PRE_D}${CLR_PRE}${prefix}${CLR_RST}"

    colorReset
}

function getReadyTempPath()
{
    local dirty="$(readlink -m ${1})"
    local rmdir=${2:-true}
    local ddiff="${dirty/$DIR_CWD/good}"

    if [[ "${ddiff:0:4}" != "good" ]]
    then
        clean="$(readlink -m ${DIR_CWD}/build/bldr-fallback/)"
    else
        clean="$(readlink -m ${dirty})"
    fi

    if [[ ${rmdir} == true ]]
    then
        rm -fr "${clean}"
    fi

    mkdir -p "${clean}"

    echo "${clean}/"
}

function getReadyTempFilePath()
{
    local dirty="${1}"
    local rmdir=${2:-true}
    local dirp="$(getReadyTempPath $(dirname ${dirty}) false)"
    local file="$(basename ${dirty})"
    local clean="$(readlink -m ${dirp}/${file})"

    if [[ ${rmdir} == true ]]
    then
        rm -fr "${clean}"
    fi

    touch "${clean}"

    echo "${clean}"
}

function inverseBoolValueAsInt()
{
    if [[ ${1:-x} == 0 ]]
    then
        echo 1
    else
        echo 0
    fi
}

function parseYaml()
{
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')

   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function getVersionOfHhvm()
{
    local v="$(hhvm --version 2> /dev/null |\
        grep -P -o '(VM)\s*([0-9]{1,2}\.){2}([0-9]{1,2})(-dev)?' 2> /dev/null |\
        cut -d' ' -f2 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 5 ]] || [[ ${len} -gt 13 ]]
    then
        echo ""
    else
        echo "${v}"
    fi
}

function getVersionOfHhvmCompiler()
{
    local v="$(hhvm --version 2> /dev/null |\
        grep -P -o '(Compiler:)\s*([^\n]*)' 2> /dev/null |\
        cut -d' ' -f2 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 8 ]]
    then
        echo ""
    else
        echo "${v}"
    fi
}

function getVersionOfHhvmRepoSchema()
{
    local v="$(hhvm --version 2> /dev/null |\
        grep -P -o '(schema:)\s*([^\n]*)' 2> /dev/null |\
        cut -d' ' -f2 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 8 ]]
    then
        echo ""
    else
        echo "${v}"
    fi
}

function getVersionOfPhp()
{
    local v="$(${BIN_PHP} -v 2> /dev/null |\
        grep -P -o '(PHP|php)\s*([0-9]{1,2}\.){2}([0-9]{1,2})' 2> /dev/null |\
        cut -d' ' -f2 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 5 ]] || [[ ${len} -gt 9 ]]
    then
        echo ""
    else
        echo "${v}"
    fi
}

function getVersionOfPhpOpcache()
{
    local v="$(${BIN_PHP} -v 2> /dev/null |\
        grep -P -o '(OPcache)\s*v([0-9]{1,2}\.){2}([0-9]{1,2})(-[a-z]+)?' 2> /dev/null |\
        cut -d' ' -f2 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 5 ]]
    then
        echo ""
    else
        echo "${v:1}"
    fi
}

function getVersionOfPhpXdebug()
{
    local v="$(${BIN_PHP} -v 2> /dev/null |\
        grep -P -o '(Xdebug)\s*v([0-9]{1,2}\.){2}([0-9]{1,2})([a-zA-Z0-9-]+)?' 2> /dev/null |\
        cut -d' ' -f2 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 5 ]]
    then
        echo ""
    else
        echo "${v:1}"
    fi
}

function getVersionOfPhpEnv()
{
    local v="$(${BIN_PHPENV} -v 2> /dev/null |\
        grep -P -o '(ENV|env)\s*([0-9]{1,2}\.){2}([0-9]{1,2})([0-9a-z-]+)?' 2> /dev/null |\
        cut -d' ' -f2 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 5 ]]
    then
        echo ""
    else
        echo "${v}"
    fi
}

function getVersionOfPhpEngApi()
{
    local v="$(${BIN_PHPIZE} -v 2> /dev/null |\
        grep -o -P '[0-9]{8,9}' 2> /dev/null |\
        head -n 1 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 8 ]] || [[ ${len} -gt 10 ]]
    then
        echo ""
    else
        echo "${v}"
    fi
}

function getVersionOfPhpModApi()
{
    local v="$(${BIN_PHPIZE} -v 2> /dev/null |\
        grep -o -P '[0-9]{8,9}' 2> /dev/null |\
        tail -n 1 2> /dev/null)"
    local len="$(echo "${v}" | wc -m)"

    if [[ ${len} -lt 8 ]] || [[ ${len} -gt 10 ]]
    then
        echo ""
    else
        echo "${v}"
    fi
}

function getMajorPHPVersion()
{
    if [ ${VER_PHP_ON_5} ]
    then
        echo "5"
    elif [ ${VER_PHP_ON_7} ]
    then
        echo "7"
    else
        echo "x"
    fi
}

function isExtensionEnabled()
{
    ${BIN_PHP} -m 2> /dev/null | grep ${1} &>> /dev/null

    if [ $? -eq 0 ]
    then
        echo "true"
    else
        echo "false"
    fi
}

function isExtensionPeclInstalled()
{
    local e="${1}"

    if [[ $? == 1 ]]
    then
        echo false
        return
    fi

    if [[ "${BIN_PECL}" == "" ]] || [[ ! -x "${BIN_PECL:-x}" ]]; then
        echo "false"
        return
    fi

    if [[ "${BIN_PECL}" == "" ]];
    then
        echo "false"
        return
    fi

    ${BIN_PECL} &>> /dev/null

    if [[ $? != 0 ]]
    then
        echo "false"
        return
    fi

    ${BIN_PECL} list | grep "${1}" &>> /dev/null

    if [ $? -eq 0 ]
    then
        echo "true"
    else
        echo "false"
    fi
}

function commaToOtherSeparated()
{
    echo $(echo $(echo "${1}" | tr ',' "${2}"))
}

function commaToSpaceSeparated()
{
    commaToOtherSeparated "${1}" " "
}

function valueInList()
{
    local needle="${1:-x}"
    local haystack="${2:-}"

    for item in $(commaToSpaceSeparated ${haystack})
    do
        echo $item
        if [ ${item} == ${needle} ]
        then
            echo "true"
            return
        fi
    done

    echo "false"
}

function assignIndirect()
{
    if [ "${1:-x}" == "x" ]; then return; fi

    export -n "${1}"="${2:-}"
}

function getYesOrNoForCompare()
{
    if [[ "${1:-x}" == "${2:-y}" ]]
    then
        echo "YES"
    else
        echo "NO"
    fi
}


