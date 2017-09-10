#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

SCRIPT_SELF_PATH="${0}"
SCRIPT_SELF_BASE="$(basename ${0})"
SCRIPT_SELF_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

type writeLines &>> /dev/null || . ${SCRIPT_SELF_REAL}/../_common/bash-inc_all.bash

if [ -z ${MOD_NAME} ]
then
    MOD_NAME="$(basename ${SCRIPT_SELF_BASE} .bash)"
fi

MOD_SOURCE_CONFIG="${INC_PHP_EXTS_PATH}/php-$(getMajorPHPVersion)/${MOD_NAME}.bash"

if [ ! -f ${MOD_SOURCE_CONFIG} ]
then
    writeError "Could not find valid script \"${MOD_SOURCE_CONFIG}\"."
fi

writeSectionEnter "Install \"${MOD_NAME}\" extension."

MOD_PECL_CMD=false
MOD_PECL_CMD_URL=false
MOD_PECL_DL=false
MOD_PECL_DL_NAME=false
MOD_PECL_GIT=false
MOD_PECL_GIT_BRANCH="master"
MOD_PECL_GIT_DIR=""
MOD_PECL_FLAGS=""
MOD_PECL_CD=false
MOD_PECL_RET=0
MOD_RESULT=0

writeActionSourcedFile "${MOD_SOURCE_CONFIG}"

. ${MOD_SOURCE_CONFIG}

MOD_PECL_LOG=$(getReadyTempFilePath "${LOG_EXT}/${MOD_NAME//[^A-Za-z0-9._-]/_}.log")
MOD_PECL_BLD=$(getReadyTempPath "${BLD_EXT}/${MOD_NAME//[^A-Za-z0-9._-]/_}")

if [[ $(isExtensionEnabled ${MOD_NAME}) == "true" ]] && [[ $(isExtensionPeclInstalled ${MOD_NAME}) == "true" ]]
then
    appendLogBufferLines "${CMD_PRE}pecl uninstall ${MOD_NAME} &>> /dev/null"

    ${CMD_PRE} pecl uninstall ${MOD_NAME} &>> ${MOD_PECL_LOG} || \
        writeWarning "Failed to remove previous install; blindly attempting to continue anyway."
fi

if [[ ${MOD_PECL_CMD} != false ]]
then

    if [[ ${MOD_PECL_CMD_URL} == false ]]
    then
        MOD_PECL_CMD_URL="${MOD_NAME}"
    fi

    appendLogBufferLines "${CMD_PRE}pecl install --force ${MOD_PECL_CMD_URL}" &&\
        flushLogBufferLines

    printf "\n" | ${CMD_PRE} pecl install --force ${MOD_PECL_CMD_URL} &>> "${MOD_PECL_LOG}" || \
        MOD_PECL_RET=$?

elif [[ ${MOD_PECL_DL} != false ]] || [[ ${MOD_PECL_GIT} != false ]]
then

    appendLogBufferLines "cd ${MOD_PECL_BLD}"

    cd ${MOD_PECL_BLD}

    if [[ ${MOD_PECL_DL} != false ]]
    then

        if [[ ${MOD_PECL_DL_NAME} == false ]]
        then
            MOD_PECL_DL_NAME="${MOD_NAME}"
        fi

        appendLogBufferLines "${BIN_CURL} -o ${MOD_NAME}.tar.gz https://pecl.php.net/get/${MOD_PECL_DL_NAME}"

        ${BIN_CURL} -o ${MOD_NAME}.tar.gz https://pecl.php.net/get/${MOD_NAME} &>> ${MOD_PECL_LOG} || \
            MOD_PECL_RET=$?

        appendLogBufferLines "${BIN_TAR} xzf ${MOD_NAME}.tar.gz && cd [...]"

        ${BIN_TAR} xzf ${MOD_NAME}.tar.gz &>> ${MOD_PECL_LOG} || \
            MOD_PECL_RET=$?

    else

        appendLogBufferLines "${BIN_GIT} clone ${MOD_PECL_GIT} ${MOD_NAME} && cd [...]" && \
            appendLogBufferLines "${BIN_GIT} checkout ${MOD_PECL_GIT_BRANCH:-master}"

        ${BIN_GIT} clone -b ${MOD_PECL_GIT_BRANCH:-master} ${MOD_PECL_GIT} ${MOD_NAME} &>> ${MOD_PECL_LOG} || \
            MOD_PECL_RET=$?

    fi

    if [[ ${MOD_PECL_CD} != false ]] && [[ -d ${MOD_PECL_CD} ]]
    then
        cd ${MOD_PECL_CD} &>> ${MOD_PECL_LOG}
    elif [[ -d ${MOD_NAME} ]]
    then
        cd ${MOD_NAME} &>> ${MOD_PECL_LOG}
    else
        cd ${MOD_NAME}* &>> ${MOD_PECL_LOG}
    fi

    ${BIN_PHPIZE} &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    appendLogBufferLines "${BIN_PHPIZE}" && \
        appendLogBufferLines "./configure ${MOD_PECL_FLAGS}" && \
        appendLogBufferLines "${BIN_MAKE}" && \
        appendLogBufferLines "${BIN_MAKE} install" && \
        flushLogBufferLines

    printf "\n" | ./configure ${MOD_PECL_FLAGS} &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    ${BIN_MAKE} &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    ${BIN_MAKE} install &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    cd "$DIR_CWD"
fi

if [[ ${MOD_PECL_RET} == 0 ]] && [[ $(isExtensionEnabled ${MOD_NAME}) != "true" ]]; then
    if [ ${BIN_PHPENV} ]
    then
        writeExecuted "${BIN_PHPENV} config-add ${INC_PHP_CONF_PATH}/${MOD_NAME}.ini"
        ${BIN_PHPENV} config-add "${INC_PHP_CONF_PATH}/${MOD_NAME}.ini" &>> /dev/null || \
            writeWarning "Could not add ${MOD_NAME}.ini to PHP config."

        writeExecuted "${BIN_PHPENV} conf add ${INC_PHP_CONF_PATH}/${MOD_NAME}.ini"
        ${BIN_PHPENV} conf add "${INC_PHP_CONF_PATH}/${MOD_NAME}.ini" &>> /dev/null || \
            writeWarning "Could not add ${MOD_NAME}.ini to PHP config."

        writeExecuted "${BIN_PHPENV} conf enable ${MOD_NAME}"
        ${BIN_PHPENV} conf enable "${MOD_NAME}" &>> /dev/null || \
            writeWarning "Could not add ${MOD_NAME} to PHP config."

        writeExecuted "${BIN_PHPENV} rehash"

        ${BIN_PHPENV} rehash
    else
        writeWarning \
            "Auto-enabling extensions is only supported in phpenv environments." \
            "You need to add \"extension=${MOD_NAME}.so\" to enable the extension."
    fi
fi

if [[ ${MOD_PECL_RET} == 0 ]]
then
    writeSectionExit "Install \"${MOD_NAME}\" extension."
else
    writeFailedLogOutput "${MOD_PECL_LOG}" "${MOD_NAME}"
    writeSectionExit "Install \"${MOD_NAME}\" extension."
fi

