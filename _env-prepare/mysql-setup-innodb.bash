#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_RUN_ACTION_INSTRUCTIONS_SQL=(
	"set global innodb_large_prefix = true"
	"set global innodb_file_per_table = true"
	"set global innodb_file_format = 'barracuda'"
)

