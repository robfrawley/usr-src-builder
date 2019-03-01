#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_SCRIPT_SELF_PATH="${0}"
_SCRIPT_SELF_BASE="$(basename ${0})"
_SCRIPT_SELF_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

type writeLines &>> /dev/null || . ${_SCRIPT_SELF_REAL}/../_common/bash-inc_all.bash

if [ -z ${_MOD_NAME} ]
then
    _MOD_NAME="$(basename ${_SCRIPT_SELF_BASE} .bash)"
fi

_MOD_SOURCE_CONFIG="${_INC_PHP_EXTS_PATH}/php-$(getMajorPHPVersion)/${_MOD_NAME}.bash"

if [ ! -f ${_MOD_SOURCE_CONFIG} ]
then
    writeError "Could not find valid script \"${_MOD_SOURCE_CONFIG}\"."
fi

writeSectionEnter "Install \"${_MOD_NAME}\" extension."

_MOD_PECL_CMD=false
_MOD_PECL_CMD_URL=false
_MOD_PECL_DL=false
_MOD_PECL_DL_NAME=false
_MOD_PECL_GIT=false
_MOD_PECL_GIT_BRANCH="master"
_MOD_PECL_GIT_DIR=""
_MOD_PECL_FLAGS=""
_MOD_PECL_CD=false
_MOD_PECL_RET=0
_MOD_RESULT=0

writeActionSourcedFile "${_MOD_SOURCE_CONFIG}"

. ${_MOD_SOURCE_CONFIG}

_MOD_PECL_LOG=$(getReadyTempFilePath "${_LOG_EXT}/${_MOD_NAME//[^A-Za-z0-9._-]/_}.log")
_MOD_PECL_BLD=$(getReadyTempPath "${_BLD_EXT}/${_MOD_NAME//[^A-Za-z0-9._-]/_}")

if [[ $(isExtensionEnabled ${_MOD_NAME}) == "true" ]] && [[ $(isExtensionPeclInstalled ${_MOD_NAME}) == "true" ]]
then
    appendLogBufferLines "${_CMD_PRE}pecl uninstall ${_MOD_NAME} &>> /dev/null"

    ${_CMD_PRE} pecl uninstall ${_MOD_NAME} &>> ${_MOD_PECL_LOG} || \
        writeWarning "Failed to remove previous install; blindly attempting to continue anyway."
fi

if [[ ${_MOD_PECL_CMD} != false ]]
then

    if [[ ${_MOD_PECL_CMD_URL} == false ]]
    then
        _MOD_PECL_CMD_URL="${_MOD_NAME}"
    fi

    appendLogBufferLines "${_CMD_PRE}pecl install --force ${_MOD_PECL_CMD_URL}" &&\
        flushLogBufferLines

    printf "\n" | ${_CMD_PRE} pecl install --force ${_MOD_PECL_CMD_URL} &>> "${_MOD_PECL_LOG}" || \
        _MOD_PECL_RET=$?

elif [[ ${_MOD_PECL_DL} != false ]] || [[ ${_MOD_PECL_GIT} != false ]]
then

    appendLogBufferLines "cd ${_MOD_PECL_BLD}"

    cd ${_MOD_PECL_BLD}

    if [[ ${_MOD_PECL_DL} != false ]]
    then

        if [[ ${_MOD_PECL_DL_NAME} == false ]]
        then
            _MOD_PECL_DL_NAME="${_MOD_NAME}"
        fi

        appendLogBufferLines "${_BIN_CURL} -o ${_MOD_NAME}.tar.gz https://pecl.php.net/get/${_MOD_PECL_DL_NAME}"

        ${_BIN_CURL} -o ${_MOD_NAME}.tar.gz https://pecl.php.net/get/${_MOD_NAME} &>> ${_MOD_PECL_LOG} || \
            _MOD_PECL_RET=$?

        appendLogBufferLines "${_BIN_TAR} xzf ${_MOD_NAME}.tar.gz && cd [...]"

        ${_BIN_TAR} xzf ${_MOD_NAME}.tar.gz &>> ${_MOD_PECL_LOG} || \
            _MOD_PECL_RET=$?

    else

        appendLogBufferLines "${_BIN_GIT} clone ${_MOD_PECL_GIT} ${_MOD_NAME} && cd [...]" && \
            appendLogBufferLines "${_BIN_GIT} checkout ${_MOD_PECL_GIT_BRANCH:-master}"

        ${_BIN_GIT} clone -b ${_MOD_PECL_GIT_BRANCH:-master} ${_MOD_PECL_GIT} ${_MOD_NAME} &>> ${_MOD_PECL_LOG} || \
            _MOD_PECL_RET=$?

    fi

    if [[ ${_MOD_PECL_CD} != false ]] && [[ -d ${_MOD_PECL_CD} ]]
    then
        cd ${_MOD_PECL_CD} &>> ${_MOD_PECL_LOG}
    elif [[ -d ${_MOD_NAME} ]]
    then
        cd ${_MOD_NAME} &>> ${_MOD_PECL_LOG}
    else
        cd ${_MOD_NAME}* &>> ${_MOD_PECL_LOG}
    fi

    ${_BIN_PHPIZE} &>> ${_MOD_PECL_LOG} || \
        _MOD_PECL_RET=$?

    appendLogBufferLines "${_BIN_PHPIZE}" && \
        appendLogBufferLines "./configure ${_MOD_PECL_FLAGS}" && \
        appendLogBufferLines "${_BIN_MAKE}" && \
        appendLogBufferLines "${_BIN_MAKE} install" && \
        flushLogBufferLines

    printf "\n" | ./configure ${_MOD_PECL_FLAGS} &>> ${_MOD_PECL_LOG} || \
        _MOD_PECL_RET=$?

    ${_BIN_MAKE} &>> ${_MOD_PECL_LOG} || \
        _MOD_PECL_RET=$?

    ${_BIN_MAKE} install &>> ${_MOD_PECL_LOG} || \
        _MOD_PECL_RET=$?

    cd "$_DIR_CWD"
fi

if [[ ${_MOD_PECL_RET} == 0 ]] && [[ $(isExtensionEnabled ${_MOD_NAME}) != "true" ]]; then
    if [ ${_BIN_PHPENV} ]
    then
        writeExecuted "${_BIN_PHPENV} config-add ${_INC_PHP_CONF_PATH}/${_MOD_NAME}.ini"
        ${_BIN_PHPENV} config-add "${_INC_PHP_CONF_PATH}/${_MOD_NAME}.ini" &>> /dev/null || \
            writeWarning "Could not add ${_MOD_NAME}.ini to PHP config."

        writeExecuted "${_BIN_PHPENV} conf add ${_INC_PHP_CONF_PATH}/${_MOD_NAME}.ini"
        ${_BIN_PHPENV} conf add "${_INC_PHP_CONF_PATH}/${_MOD_NAME}.ini" &>> /dev/null || \
            writeWarning "Could not add ${_MOD_NAME}.ini to PHP config."

        writeExecuted "${_BIN_PHPENV} conf enable ${_MOD_NAME}"
        ${_BIN_PHPENV} conf enable "${_MOD_NAME}" &>> /dev/null || \
            writeWarning "Could not add ${_MOD_NAME} to PHP config."

        writeExecuted "${_BIN_PHPENV} rehash"

        ${_BIN_PHPENV} rehash
    else
        writeWarning \
            "Auto-enabling extensions is only supported in phpenv environments." \
            "You need to add \"extension=${_MOD_NAME}.so\" to enable the extension."
    fi
fi

if [[ ${_MOD_PECL_RET} == 0 ]]
then
    writeSectionExit "Install \"${_MOD_NAME}\" extension."
else
    writeFailedLogOutput "${_MOD_PECL_LOG}" "${_MOD_NAME}"
    writeSectionExit "Install \"${_MOD_NAME}\" extension."
fi

