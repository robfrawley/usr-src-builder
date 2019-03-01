#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _BLD_COVERALLS_BIN_PATH=''
export _BLD_COVERALLS_BIN_OPTS='-vvv --ansi'

_BLD_COVERALLS_BIN_LIST=()
_BLD_COVERALLS_BIN_LIST+=("${_DIR_CWD}/bin/php-coveralls")
_BLD_COVERALLS_BIN_LIST+=("${_DIR_CWD}/bin/coveralls")
_BLD_COVERALLS_BIN_LIST+=("${_DIR_CWD}/vendor/bin/php-coveralls")
_BLD_COVERALLS_BIN_LIST+=("${_DIR_CWD}/vendor/bin/coveralls")

for i in "${!_BLD_COVERALLS_BIN_LIST[@]}"; do
    if [[ -f ${_BLD_COVERALLS_BIN_LIST[$i]} ]]; then
        _BLD_COVERALLS_BIN_PATH="$(
            readlink -m "${_BLD_COVERALLS_BIN_LIST[$i]}"
        )" && break
    fi
done

if [[ -n "${_BLD_CLOVER_XML_FILE}" ]]; then
    _BLD_COVERALLS_BIN_OPTS+=" -x ${_BLD_CLOVER_XML_FILE}"
fi
