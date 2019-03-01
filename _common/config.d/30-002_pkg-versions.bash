#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _VER_ENV_DIST_SUPPORTED="wily,vivid,trusty,precise"
export _VER_PHP_ON_7="false"
export _VER_PHP_ON_5="false"
export _VER_PHP_ON_UNSU="true"

case "${_VER_PHP}" in
    7*)
        _VER_PHP_ON_7="true"
        _VER_PHP_ON_UNSU="false"
        ;;
    5.6*)
        _VER_PHP_ON_5="true"
        _VER_PHP_ON_UNSU="false"
        ;;
esac
