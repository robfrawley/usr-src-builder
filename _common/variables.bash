#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

if _BIN_FIND="$(which find)"; then
    for f in $(${_BIN_FIND} "$(readlink -m ${_BLDR_PATH_NAME})/_common/config.d" -type f -print0 2> /dev/null | sort -z -n | xargs -0); do
        source "${f}" || \
            writeError 'Failed to source require configuration file: ' "${f}"
    done
else
    writeError 'Failed to source required configuration files: missing "find" command!'
fi
