#!/bin/bash
set +o posix
set -xv

source ../functions.sh

echo -en "\n ENVIRONMENT=$ENVIRONMENT"
echo -en "\n RW_PWD=$RW_PWD"
echo -en "\n RO_PWD=$RO_PWD"

###$login_cmd_dbname -c "SELECT current_version FROM $DB_VERSION_TABLENAME"

#$login_cmd_dbname -c "ALTER USER $DBNAME WITH PASSWORD '$RW_PWD'"

#$login_cmd_dbname -c "ALTER USER ${DBNAME}_ro WITH PASSWORD '$RO_PWD'"



