#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_BLD_CLOVER_XML_LIST=()
_BLD_CLOVER_XML_LIST+=("${_DIR_CWD}/build/logs/clover.xml")
_BLD_CLOVER_XML_LIST+=("${_DIR_CWD}/build/logs/coverage.xml")
_BLD_CLOVER_XML_LIST+=("${_DIR_CWD}/build/logs/coverage-clover.xml")
_BLD_CLOVER_XML_LIST+=("${_DIR_CWD}/var/build/clover.xml")
_BLD_CLOVER_XML_LIST+=("${_DIR_CWD}/var/build/coverage.xml")
_BLD_CLOVER_XML_LIST+=("${_DIR_CWD}/var/build/coverage-clover.xml")

for i in "${!_BLD_CLOVER_XML_LIST[@]}"; do
    if [[ -f ${_BLD_CLOVER_XML_LIST[$i]} ]]; then
        export _BLD_CLOVER_XML_FILE="$(
            readlink -m "${_BLD_CLOVER_XML_LIST[$i]}"
        )"
    fi
done
