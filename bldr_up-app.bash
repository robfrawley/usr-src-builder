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

export BLD_MODE="app prep"
export BLD_MODE_DESC="Application Prepare"
export BLD_MODE_APPEND=false
export BLD_INCS=($(commaToSpaceSeparated ${scr_pkg_app_prep}))
export BLD_PATH=${INC_APP_PREP_PATH}

writeDebugSourcedFile "${BLD_PATH}/_app-prepare.bash"
. "${BLD_PATH}/_app-prepare.bash"

