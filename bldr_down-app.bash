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

export _BLD_MODE="app post"
export _BLD_MODE_DESC="application-tear-down"
export _BLD_MODE_APPEND=false
export _BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_app_post}))
export _BLD_PATH=${_INC_APP_POST_PATH}

writeDebugSourcedFile "${_BLD_PATH}/_app-cleanup.bash"
. "${_BLD_PATH}/_app-cleanup.bash"

