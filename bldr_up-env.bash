#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

type outLines &>> /dev/null || exit -1

export RT_MODE="env make"
export RT_MODE_DESC="Environment Make"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_make}))
export RT_PATH=${INC_ENV_MAKE_PATH}

opSource "${RT_PATH}/_env-build.bash"
. "${RT_PATH}/_env-build.bash"

export RT_MODE="env prep"
export RT_MODE_DESC="Environment Prepare"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_prep}))
export RT_PATH=${INC_ENV_PREP_PATH}

opSource "${RT_PATH}/_env-prepare.bash"
. "${RT_PATH}/_env-prepare.bash"

export RT_MODE="use"
export RT_MODE_DESC="PHP Extension Install"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_php_exts}))
export RT_PATH=${INC_PHP_EXTS_PATH}

opSource "${RT_PATH}/_php-extensions.bash"
. "${RT_PATH}/_php-extensions.bash"

if [ ${BIN_PHPENV} ]
then
    export RT_MODE="inc"
    export RT_MODE_DESC="PHP INI Config"
    export RT_MODE_APPEND=false
    export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_php_conf}))
    export RT_PATH=${INC_PHP_CONF_PATH}

    opSource "${RT_PATH}/_php-configuration.bash"
    . "${RT_PATH}/_php-configuration.bash"
else
	outWarning "Cannot add/setup configuration INI outside PHPENV environments."
fi

# EOF #
