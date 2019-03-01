#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export _VER_HHVM="$(getVersionOfHhvm)"
export _VER_HHVM_COMPILER="$(getVersionOfHhvmCompiler)"
export _VER_HHVM_REPO_SCHEMA="$(getVersionOfHhvmRepoSchema)"
export _VER_PHP="$(getVersionOfPhp)"
export _VER_PHPENV="$(getVersionOfPhpEnv)"
export _VER_PHPAPI_ENG="$(getVersionOfPhpEngApi)"
export _VER_PHPAPI_MOD="$(getVersionOfPhpModApi)"
export _VER_PHP_OPCACHE="$(getVersionOfPhpOpcache)"
export _VER_PHP_XDEBUG="$(getVersionOfPhpXdebug)"
