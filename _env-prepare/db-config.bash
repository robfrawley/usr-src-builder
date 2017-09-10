#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RUN_ACTION_INSTRUCTIONS_CMD=(
  "bash ${DIR_CWD}/config.sh"
  "rm -fr ${DIR_CWD}/config.sh ${DIR_CWD}/config.sql"
)

BLD_MYSQL_ACT=(

)

echo "SET @@GLOBAL.default_storage_engine=InnoDB;" > "${DIR_CWD}/config.sql"
echo "SET @@GLOBAL.innodb_strict_mode=1;" >> "${DIR_CWD}/config.sql"
echo "SET @@GLOBAL.innodb_file_per_table=1;" >> "${DIR_CWD}/config.sql"
echo "SET @@GLOBAL.innodb_file_format=Barracuda;" >> "${DIR_CWD}/config.sql"
echo "SET @@GLOBAL.innodb_large_prefix=1;" >> "${DIR_CWD}/config.sql"
echo "SET @@GLOBAL.character_set_server=utf8mb4;" >> "${DIR_CWD}/config.sql"
echo "SET @@GLOBAL.collation_server=utf8mb4_unicode_ci;" >> "${DIR_CWD}/config.sql"
echo "mysql -uroot < config.sql" > "${DIR_CWD}/config.sh"

