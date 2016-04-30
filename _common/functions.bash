#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

function newLine()
{
    echo -en "\n"
}

function outLines()
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
        outPrefix "${p}"
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
            newLine
            if [[ ${OUT_PRE_LINE} == true ]]
            then
                outPrefix "${p}"
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
        newLine
        OUT_NEW_LINE=true
    else
        OUT_NEW_LINE=true
    fi

    OUT_SPACE_F=1
    OUT_SPACE_N=1
    OUT_PRE_LINE=true
}

function outTitle()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local l="${2:-BLOCK}"
    local s="${3:-true}"

    if [[ $s == true ]]
    then
        outPrefix ${p} true
        outLines ${p} "${CLR_HDR_D}${CLR_HDR}${l}${CLR_RST}"
    else
        outLines ${p} "${CLR_HDR_D}${CLR_HDR}${l}${CLR_RST}"
    fi

    if [[ $s == true ]]; then outPrefix ${p} true; fi
}

function outPrefix()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    if [[ ${3} != true ]]; then echo -en "  "; fi

    echo -en "${CLR_PRE_D}${CLR_PRE}${1}${CLR_RST}"

    if [[ ${2} == true ]]; then newLine; fi
}

function outBlkL()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    outTitle  ${p} ${t}
    outLines  ${p} ${l[@]}
    outPrefix ${p} true
}

function outBlkS()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    OUT_NEW_LINE=false
    outTitle ${p} "${t}" false
    OUT_PRE_LINE=false
    OUT_SPACE_F=0
    outLines ${p} ${l[@]}
}

function outBlkM()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    outTitle ${p} "${t}" false
    outLines ${p} ${l[@]}
}

function outSequence()
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

function opFailLogOutput()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    local f="${1}"
    local t="${2}"
    local os=" :: BUILD LOG OUTPUT [ ${t} ] |"
    local len="$((($(echo ${os} | wc -m) + 10)))"

    outWarning "The previous command(s) exited with error return code(s). Any available log" \
        "output will be dumped for review."

    sleep 2

    echo -en "  " && \
        echo -en "${CLR_L_YELLOW}+" &&\
        outSequence ${len} "-" "${CLR_L_YELLOW}" && \
        echo -en "${CLR_L_YELLOW}+\n" &&\
        echo -en "  | ${CLR_B_YELLOW}START DUMP${CLR_L_YELLOW}${os}" && \
        newLine && \
        echo -en "  +" && \
        outSequence ${len} "-" "${CLR_L_YELLOW}" && \
        echo -en "${CLR_L_YELLOW}+${CLR_RST}" &&\
        newLine

    if [[ -f ${f} ]]
    then
        cat ${f} | sed '/^\s*$/d'
    else
        echo -en "  ${CLR_B_RED}ERROR --- ${CLR_L_RED}No log output ot log file \"${f}\" is not present.${CLR_RST}" && \
            newLine
    fi

    local len="$((($(echo ${os} | wc -m) + 8)))"
    echo -en "  " && \
        echo -en "${CLR_L_YELLOW}+" &&\
        outSequence ${len} "-" "${CLR_L_YELLOW}" && \
        echo -en "${CLR_L_YELLOW}+\n" &&\
        echo -en "  ${CLR_L_YELLOW}|${CLR_B_YELLOW} END DUMP${CLR_L_YELLOW}${os}" && \
        newLine && \
        echo -en "  +" && \
        outSequence ${len} "-" "${CLR_L_YELLOW}" && \
        echo -en "${CLR_L_YELLOW}+${CLR_RST}" &&\
        newLine

    rm -fr ${f}

    sleep 2
}

function opLogBuild()
{
    LOG_BUF+=("${@}")
}

function opLogFlush()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        LOG_BUF=()
        return
    fi

    local t="${1:-MAKE}"
    local p="${2:-==}"

    if [[ ${#LOG_BUF[@]} -lt 1 ]]
    then
        outWarning "No log build lines to flush."
    fi

    for l in "${LOG_BUF[@]}"
    do
        colorSet "${CLR_L_BLUE}" "${CLR_L_BLUE}"

        OUT_NEW_LINE=false
        outTitle ${p} ${t} false

        OUT_PRE_LINE=false && OUT_SPACE_F=0 && OUT_SPACE_N=5
        outLines ${p} "${l[@]}"
    done

    colorReset
    newLine
}

function colorSet()
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

function opStart()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorSet "${CLR_L_GREEN}" "${CLR_L_GREEN}" "${CLR_L_WHITE}"
    outBlkM ">>" "OPEN" "${@}"
    colorReset
}

function opStartSection()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorSet "${CLR_WHITE}" "${CLR_L_WHITE}" "${CLR_WHITE}"
    outBlkS "--" "OPEN" "${@}"
    colorReset
}

function opDone()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorSet "${CLR_L_GREEN}" "${CLR_L_GREEN}" "${CLR_L_WHITE}"
    outBlkM "<<" "STOP" "${@}"
    colorReset
}

function opDoneSection()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorSet "${CLR_WHITE}" "${CLR_L_WHITE}" "${CLR_WHITE}"
    outBlkS "--" "STOP" "${@}"
    colorReset
}

function opFail()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorSet "${CLR_L_RED}" "${CLR_L_RED}" "${CLR_L_RED}"
    outBlkM "##" "FAIL" "${@}"
    colorReset
}

function opFailSection()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorSet "${CLR_WHITE}" "${CLR_L_WHITE}" "${CLR_WHITE}"
    outBlkS "##" "FAIL" "${@}"
    colorReset
}

function opExec()
{
    if [[ "${B_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorSet "${CLR_L_PURPLE}" "${CLR_L_PURPLE}"
    outBlkS "++" "CALL" "${@}"
    colorReset
}

function opSource()
{
    if [[ ${OUT_TYPE_SOURCE} == false ]]
    then
        return
    fi

    colorSet "${CLR_YELLOW}" "${CLR_YELLOW}"
    outBlkS "--" "INCS" "${@}"
    colorReset
}

function outInfo()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorSet "${CLR_YELLOW}" "${CLR_YELLOW}"
    outBlkS "--" "INFO" "${@}"
    colorReset
}

function outWarning()
{
    if [[ "${B_QUIET}" -eq 1 ]]; then
        return
    fi

    colorSet "${CLR_L_RED}" "${CLR_L_RED}"
    outBlkL "!!" "WARN" "${@}"
    colorReset
}

function outError()
{
    if [[ "${B_VERY_QUIET}" -eq 1 ]]; then
        return
    fi

    colorSet "${CLR_L_RED}" "${CLR_B_RED}" "${CLR_L_WHITE}"
    outBlkL "##" "CRIT" "${@}"
    colorReset
    exit -1
}

function outComplete()
{
    if [[ "${B_VERY_VERBOSE}" -ne 1 ]]; then
        return
    fi

    colorSet "${CLR_L_WHITE}" "${CLR_L_WHITE}" "${CLR_L_WHITE}"
    outBlkL "--" "EXITING" "${@}"
    colorReset
}

function outListing()
{
    if [[ "${B_VERY_VERBOSE}" -ne 1 ]]; then
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

# EOF #

