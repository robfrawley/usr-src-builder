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

export RT_MODE="app post"
export RT_MODE_DESC="Application Post-run"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_app_post}))
export RT_PATH=${INC_APP_POST_PATH}

opSource "${RT_PATH}/_app-cleanup.bash"
. "${RT_PATH}/_app-cleanup.bash"

# EOF #
