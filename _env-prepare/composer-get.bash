#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_RUN_ACTION_INSTRUCTIONS_CMD=(
	"${_BIN_CURL} -o ${_DIR_CWD}/composer.raw -sS https://getcomposer.org/installer"
    "${_BIN_PHP} ${_DIR_CWD}/composer.raw -- --filename=composer --install-dir=${_DIR_CWD}"
    "rm -fr ${_DIR_CWD}/composer.raw"
    "chmod u+x ${_DIR_CWD}/composer"
)

