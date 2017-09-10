#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

if [ -z ${B_VERY_QUIET+x} ]; then
    export B_VERY_QUIET=0
fi

if [ -z ${B_QUIET+x} ]; then
    export B_QUIET=0
fi

if [ -z ${B_VERBOSE+x} ]; then
    export B_VERBOSE=0
fi

if [ -z ${B_VERY_VERBOSE+x} ]; then
    export B_VERY_VERBOSE=0
fi

if [ -z ${B_DEBUG+x} ]; then
    export B_DEBUG=0
fi

export CMD_PRE=""
export CMD_ENV=""

export DIR_CWD="$(pwd)"
export TMP_DIR="$(readlink -m "${DIR_CWD}/var")"

export LOG_ALL=()
export LOG_BUF=()
export LOG_DIR="$(getReadyTempPath "${TMP_DIR}/bldr/logs")"
export LOG_GEN="$(getReadyTempPath "${LOG_DIR}")"
export LOG_EXT="$(getReadyTempPath "${LOG_DIR}/php-extensions")"
export LOG_APP="$(getReadyTempPath "${LOG_DIR}/application")"
export LOG_ENV="$(getReadyTempPath "${LOG_DIR}/environment")"

export BLD_ALL=()
export BLD_DIR="$(getReadyTempPath "${TMP_DIR}/bldr/work")"
export BLD_GEN="$(getReadyTempPath "${BLD_DIR}")"
export BLD_EXT="$(getReadyTempPath "${BLD_DIR}/php-extensions")"
export BLD_APP="$(getReadyTempPath "${BLD_DIR}/application")"
export BLD_ENV="$(getReadyTempPath "${BLD_DIR}/environment")"

export BIN_PECL="$(which pecl)"
export BIN_CURL="$(which curl)"
export BIN_TAR="$(which tar)"
export BIN_MAKE="$(which make)"
export BIN_GIT="$(which git)"
export BIN_PHP="$(which php)"
export BIN_PHPENV="$(which phpenv)"
export BIN_PHPIZE="$(which phpize)"
export BIN_HHVM="$(which hhvm)"

export VER_HHVM="$(getVersionOfHhvm)"
export VER_HHVM_COMPILER="$(getVersionOfHhvmCompiler)"
export VER_HHVM_REPO_SCHEMA="$(getVersionOfHhvmRepoSchema)"
export VER_PHP="$(getVersionOfPhp)"
export VER_PHPENV="$(getVersionOfPhpEnv)"
export VER_PHPAPI_ENG="$(getVersionOfPhpEngApi)"
export VER_PHPAPI_MOD="$(getVersionOfPhpModApi)"
export VER_PHP_OPCACHE="$(getVersionOfPhpOpcache)"
export VER_PHP_XDEBUG="$(getVersionOfPhpXdebug)"

export VER_PHP_ON_7=""
export VER_PHP_ON_5=""
export VER_PHP_ON_UNSU=""

export VER_ENV_DIST_SUPPORTED="wily,vivid,trusty,precise"

export PKG_YML_FILEPATH=".bldr.yml"
export PKG_PRE_VARIABLE="scr_pkg_"
export PKG_ENV_VARIABLE="${build_package:-x}"
export PKG_REQ_VARIABLE="${PKG_PRE_VARIABLE}app_path,${PKG_PRE_VARIABLE}env_make,${PKG_PRE_VARIABLE}app_prep,${PKG_PRE_VARIABLE}app_post,${PKG_PRE_VARIABLE}env_post,${PKG_PRE_VARIABLE}php_exts,${PKG_PRE_VARIABLE}env_prep,${PKG_PRE_VARIABLE}env_post,${PKG_PRE_VARIABLE}php_conf"

export COV_PATH="$(readlink -m ${DIR_CWD}/build/logs/clover.xml)"
if [[ ! -f "${COV_PATH}" ]]; then
    export COV_PATH="$(readlink -m ${DIR_CWD}/var/build/clover.xml)"
fi

export INC_PHP_EXTS_PATH="$(readlink -m ${BLDR_PATH_NAME}/_php-extensions/)"
export INC_PHP_EXTS_FILE="php-exts_"
export INC_PHP_CONF_PATH="$(readlink -m ${BLDR_PATH_NAME}/_php-configuration/)"
export INC_PHP_CONF_FILE="php-conf_"
export INC_ENV_MAKE_PATH="$(readlink -m ${BLDR_PATH_NAME}/_env-build/)"
export INC_ENV_MAKE_FILE="env-make_"
export INC_ENV_PREP_PATH="$(readlink -m ${BLDR_PATH_NAME}/_env-prepare/)"
export INC_ENV_PREP_FILE="env-prep_"
export INC_ENV_POST_PATH="$(readlink -m ${BLDR_PATH_NAME}/_env-cleanup/)"
export INC_ENV_POST_FILE=""
export INC_APP_PREP_PATH="$(readlink -m ${BLDR_PATH_NAME}/_app-prepare/)"
export INC_APP_PREP_FILE="app-prep_"
export INC_APP_POST_PATH="$(readlink -m ${BLDR_PATH_NAME}/_app-cleanup/)"
export INC_APP_POST_FILE="app-post_"

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
export BLD_TMP_PRESERVE=false

export BLD_ENV_MAKE_VER_IMAGE_MAGIK="6.9.3-2"

if [ ${PKG_REQ_VARIABLE}} == "~" ]
then
	PKG_REQ_VARIABLE="${PKG_YML_FILEPATH}"
fi

if [ ${VER_PHP:0:1} == "7" ]
then
    VER_PHP_ON_7="true"
elif [ ${VER_PHP:0:1} == "5" ]
then
    VER_PHP_ON_5="true"
else
    VER_PHP_ON_UNSU="true"
fi

export CLR_BLACK='\e[0;30m'
export CLR_RED='\e[0;31m'
export CLR_GREEN='\e[0;32m'
export CLR_YELLOW='\e[0;33m'
export CLR_BLUE='\e[0;34m'
export CLR_PURPLE='\e[0;35m'
export CLR_CYAN='\e[0;36m'
export CLR_WHITE='\e[0;37m'

export CLR_L_BLACK='\e[0;90m'
export CLR_L_RED='\e[0;91m'
export CLR_L_GREEN='\e[0;92m'
export CLR_L_YELLOW='\e[0;93m'
export CLR_L_BLUE='\e[0;94m'
export CLR_L_PURPLE='\e[0;95m'
export CLR_L_CYAN='\e[0;96m'
export CLR_L_WHITE='\e[0;97m'

export CLR_B_BLACK='\e[1;30m'
export CLR_B_RED='\e[1;31m'
export CLR_B_GREEN='\e[1;32m'
export CLR_B_YELLOW='\e[1;33m'
export CLR_B_BLUE='\e[1;34m'
export CLR_B_PURPLE='\e[1;35m'
export CLR_B_CYAN='\e[1;36m'
export CLR_B_WHITE='\e[1;97m'

export CLR_U_BLACK='\e[4;30m'
export CLR_U_RED='\e[4;31m'
export CLR_U_GREEN='\e[4;32m'
export CLR_U_YELLOW='\e[4;33m'
export CLR_U_BLUE='\e[4;34m'
export CLR_U_PURPLE='\e[4;35m'
export CLR_U_CYAN='\e[4;36m'
export CLR_U_WHITE='\e[4;97m'

export CLR_BG_BLACK='\e[40m'
export CLR_BG_RED='\e[41m'
export CLR_BG_GREEN='\e[42m'
export CLR_BG_YELLOW='\e[43m'
export CLR_BG_BLUE='\e[44m'
export CLR_BG_PURPLE='\e[45m'
export CLR_BG_CYAN='\e[46m'
export CLR_BG_WHITE='\e[47m'

export CLR_RST='\e[0m'

export CLR_TXT_D="${CLR_WHITE}"
export CLR_PRE_D="${CLR_L_WHITE}"
export CLR_HDR_D="${CLR_WHITE}"
export CLR_TXT=""
export CLR_PRE=""
export CLR_HDR=""
export OUT_NEW_LINE=true
export OUT_PRE_LINE=true
export OUT_MAX_CHAR=100
export OUT_SPACE_F=1
export OUT_SPACE_N=1

if [[ -z ${BLD_DB_USER+x} ]]; then
	BLD_DB_USER="root"
fi

if [[ -z ${BLD_DB_PASS+x} ]]; then
	BLD_DB_PASS=""
fi

if [[ -z ${BLD_DB_NAME+x} ]]; then
	BLD_DB_NAME=""
fi

export BLD_DB_USER
export BLD_DB_PASS
export BLD_DB_NAME
