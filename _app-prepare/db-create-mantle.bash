#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RT_COMMANDS_ACT=(
    "bash ${DIR_CWD}/db-create-mantle.sh"
    "rm -fr ${DIR_CWD}/db-create-mantle.sh ${DIR_CWD}/create.sql ${DIR_CWD}/create1.sql ${DIR_CWD}/create2.sql"
)

echo "${APP_MAKE_CLI} doctrine:database:create -n && \\" > "${DIR_CWD}/db-create-mantle.sh"
echo "${APP_MAKE_CLI} doctrine:schema:update --dump-sql > ${DIR_CWD}/create.sql && \\" >> "${DIR_CWD}/db-create-mantle.sh"
echo "sed 's/ utf8 / utf8mb4 /g' -- ${DIR_CWD}/create.sql > ${DIR_CWD}/create1.sql && \\" >> "${DIR_CWD}/db-create-mantle.sh"
echo "sed 's/ utf8_unicode_ci / utf8mb4_unicode_ci /g' -- ${DIR_CWD}/create1.sql > ${DIR_CWD}/create2.sql && \\" >> "${DIR_CWD}/db-create-mantle.sh"
echo "mysql --verbose -uroot Test_ScribeMantleBundle < ${DIR_CWD}/create2.sql" >> "${DIR_CWD}/db-create-mantle.sh"

# EOF #
