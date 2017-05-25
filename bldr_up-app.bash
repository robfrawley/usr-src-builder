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

export RT_MODE="app prep"
export RT_MODE_DESC="Application Prepare"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_app_prep}))
export RT_PATH=${INC_APP_PREP_PATH}

writeSourcedFile "${RT_PATH}/_app-prepare.bash"
. "${RT_PATH}/_app-prepare.bash"

# EOF #
