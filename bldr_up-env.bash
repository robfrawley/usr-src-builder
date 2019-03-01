#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

type writeLines &>> /dev/null || exit -1

export _BLD_MODE="env make"
export _BLD_MODE_DESC="environment-build"
export _BLD_MODE_APPEND=false
export _BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_env_make}))
export _BLD_PATH=${_INC_ENV_MAKE_PATH}

writeDebugSourcedFile "${_BLD_PATH}/_env-build.bash"
. "${_BLD_PATH}/_env-build.bash"

export _BLD_MODE="env prep"
export _BLD_MODE_DESC="environment-prepare"
export _BLD_MODE_APPEND=false
export _BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_env_prep}))
export _BLD_PATH=${_INC_ENV_PREP_PATH}

writeDebugSourcedFile "${_BLD_PATH}/_env-prepare.bash"
. "${_BLD_PATH}/_env-prepare.bash"

export _BLD_MODE="use"
export _BLD_MODE_DESC="php-extensions"
export _BLD_MODE_APPEND=false
export _BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_php_exts}))
export _BLD_PATH=${_INC_PHP_EXTS_PATH}

writeDebugSourcedFile "${_BLD_PATH}/_php-extensions.bash"
. "${_BLD_PATH}/_php-extensions.bash"

if [ ${_BIN_PHPENV} ]
then
    export _BLD_MODE="inc"
    export _BLD_MODE_DESC="php-ini-configs"
    export _BLD_MODE_APPEND=false
    export _BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_php_conf}))
    export _BLD_PATH=${_INC_PHP_CONF_PATH}

    writeDebugSourcedFile "${_BLD_PATH}/_php-configuration.bash"
    . "${_BLD_PATH}/_php-configuration.bash"
else
	writeWarning "Cannot add/setup configuration INI outside PHPENV environments."
fi

