#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _INC_PHP_EXTS_PATH="$(readlink -m ${_BLDR_PATH_NAME}/_php-extensions/)"
export _INC_PHP_EXTS_FILE="php-exts_"
export _INC_PHP_CONF_PATH="$(readlink -m ${_BLDR_PATH_NAME}/_php-configuration/)"
export _INC_PHP_CONF_FILE="php-conf_"
export _INC_ENV_MAKE_PATH="$(readlink -m ${_BLDR_PATH_NAME}/_env-build/)"
export _INC_ENV_MAKE_FILE="env-make_"
export _INC_ENV_PREP_PATH="$(readlink -m ${_BLDR_PATH_NAME}/_env-prepare/)"
export _INC_ENV_PREP_FILE="env-prep_"
export _INC_ENV_POST_PATH="$(readlink -m ${_BLDR_PATH_NAME}/_env-cleanup/)"
export _INC_ENV_POST_FILE=""
export _INC_APP_PREP_PATH="$(readlink -m ${_BLDR_PATH_NAME}/_app-prepare/)"
export _INC_APP_PREP_FILE="app-prep_"
export _INC_APP_POST_PATH="$(readlink -m ${_BLDR_PATH_NAME}/_app-cleanup/)"
export _INC_APP_POST_FILE="app-post_"
