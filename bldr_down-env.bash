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

export BLD_MODE="ci"
export BLD_MODE_DESC="environment-tear-down"
export BLD_MODE_APPEND=false
export BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_env_post}))
export BLD_PATH=${INC_ENV_POST_PATH}

writeDebugSourcedFile "${INC_ENV_POST_PATH}/_env-cleanup.bash"
. "${INC_ENV_POST_PATH}/_env-cleanup.bash"

