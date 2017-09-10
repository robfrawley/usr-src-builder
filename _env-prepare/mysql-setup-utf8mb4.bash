#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RUN_ACTION_INSTRUCTIONS_SQL=(
	"set global character_set_server = 'utf8mb4'"
	"set global collation_server = 'utf8mb4_unicode_ci'"
)
