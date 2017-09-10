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

export BLD_MODE="env make"
export BLD_MODE_DESC="environment-build"
export BLD_MODE_APPEND=false
export BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_env_make}))
export BLD_PATH=${INC_ENV_MAKE_PATH}

writeDebugSourcedFile "${BLD_PATH}/_env-build.bash"
. "${BLD_PATH}/_env-build.bash"

export BLD_MODE="env prep"
export BLD_MODE_DESC="environment-prepare"
export BLD_MODE_APPEND=false
export BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_env_prep}))
export BLD_PATH=${INC_ENV_PREP_PATH}

writeDebugSourcedFile "${BLD_PATH}/_env-prepare.bash"
. "${BLD_PATH}/_env-prepare.bash"

export BLD_MODE="use"
export BLD_MODE_DESC="php-extensions"
export BLD_MODE_APPEND=false
export BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_php_exts}))
export BLD_PATH=${INC_PHP_EXTS_PATH}

writeDebugSourcedFile "${BLD_PATH}/_php-extensions.bash"
. "${BLD_PATH}/_php-extensions.bash"

if [ ${BIN_PHPENV} ]
then
    export BLD_MODE="inc"
    export BLD_MODE_DESC="php-ini-configs"
    export BLD_MODE_APPEND=false
    export BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_php_conf}))
    export BLD_PATH=${INC_PHP_CONF_PATH}

    writeDebugSourcedFile "${BLD_PATH}/_php-configuration.bash"
    . "${BLD_PATH}/_php-configuration.bash"
else
	writeWarning "Cannot add/setup configuration INI outside PHPENV environments."
fi

