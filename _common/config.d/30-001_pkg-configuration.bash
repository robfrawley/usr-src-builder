#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _PKG_YML_FILEPATH=".bldr.yml"
export _PKG_PRE_VARIABLE="scr_pkg_"
export _PKG_ENV_VARIABLE="${build_package:-x}"
export _PKG_REQ_VARIABLE="${_PKG_PRE_VARIABLE}app_path,${_PKG_PRE_VARIABLE}env_make,${_PKG_PRE_VARIABLE}app_prep,${_PKG_PRE_VARIABLE}app_post,${_PKG_PRE_VARIABLE}env_post,${_PKG_PRE_VARIABLE}php_exts,${_PKG_PRE_VARIABLE}env_prep,${_PKG_PRE_VARIABLE}env_post,${_PKG_PRE_VARIABLE}php_conf"

if [[ ${_PKG_REQ_VARIABLE}} == "~" ]]; then
    _PKG_REQ_VARIABLE="${_PKG_YML_FILEPATH}"
fi
