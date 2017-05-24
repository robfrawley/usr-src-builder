#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

type outLines &>> /dev/null || exit -1

export RT_MODE="ci"
export RT_MODE_DESC="Enviornment Post-run"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_post}))
export RT_PATH=${INC_ENV_POST_PATH}

opSource "${INC_ENV_POST_PATH}/_env-cleanup.bash"
. "${INC_ENV_POST_PATH}/_env-cleanup.bash"

# EOF #
