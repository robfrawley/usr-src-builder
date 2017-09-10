#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

readonly BLDR_COMMON_PATH_NAME="`cd $(dirname ${BASH_SOURCE[0]}) && pwd`"

. ${BLDR_COMMON_PATH_NAME}/functions.bash
. ${BLDR_COMMON_PATH_NAME}/variables.bash

. /etc/lsb-release || \
    writeError "Automatic builds only supported on Ubuntu at this time. Could not find lsb_release file."

[[ $(valueInList ${DISTRIB_CODENAME:-x} ${VER_ENV_DIST_SUPPORTED}) != "true" ]] || \
    writeError "Automatic builds only supported on OS versions (${VER_ENV_DIST_SUPPORTED}) at this time." \
    "Found version ${DISTRIB_CODENAME}."

[[ "${BIN_PHP:-x}" == "x" ]] && \
    writeError "Could not find a valid PHP binary within your configured path: \"${PATH}\"."

if [ "${BIN_HHVM:-x}" == "x" ]
then
    env_with_hhvm="no"
    env_ver_hhvm=" (HHVM    N/A)"
else
    env_with_hhvm="yes"
    env_ver_hhvm="(HHVM    v${VER_HHVM})"
fi

if [ "${TRAVIS:-x}" == "x" ]
then
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        CMD_PRE="sudo "
        env_location="local"
        env_with_phpenv="no"
        env_ver_phpenv=" (PHPEnv  N/A)"
    else
        env_location="local"
        env_with_phpenv="yes"
        env_ver_phpenv="(PHPEnv  v${VER_PHPENV})"
    fi
else
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        env_location="travis"
        env_with_phpenv="no"
        env_ver_phpenv=" (PHPEnv  n/a)"
    else
        env_location="travis"
        env_with_phpenv="yes"
        env_ver_phpenv="(PHPEnv  v${VER_PHPENV})"
    fi
fi

if [[ "${PKG_ENV_VARIABLE:-x}" == "x" || "${PKG_ENV_VARIABLE:-x}" == "true" ]]
then
    PKG_ENV_VARIABLE="${PKG_YML_FILEPATH}"
fi

if [ ! -f "${BLDR_ROOT_PATH}/${PKG_ENV_VARIABLE}" ]; then
    writeError "Unable to find the package configuration. This must be defined and set to the" \
        "location of your configuration YAML, or simply true to use the default path."
fi

eval $(parseYaml "${BLDR_ROOT_PATH}/${PKG_ENV_VARIABLE}" "${PKG_PRE_VARIABLE}")

for item in $(commaToSpaceSeparated ${PKG_REQ_VARIABLE})
do
    if [ ${item:-x} == "x" ] || [ ${!item:-x} == "x" ] || [ ${!item:-x} == "~" ]
    then
        assignIndirect "${item}" ""
    fi
done

if [[ -z "${scr_pkg_app_path}" ]]
then
    export APP_MAKE_CLI="$(readlink -m ${DIR_CWD}/app/console)"
else
    export APP_MAKE_CLI="$(readlink -m ${DIR_CWD}/${scr_pkg_app_path})"
fi

