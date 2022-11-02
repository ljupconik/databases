#!/bin/bash
set +o posix
set -xv

source ../functions.sh



#$login_cmd_dbname -c "SELECT current_version FROM $DB_VERSION_TABLENAME" -t | xargs

$login_cmd_postgres -c "ALTER USER ro RENAME TO customer_ro; ALTER USER customer_ro WITH PASSWORD '$RO_PWD';"

$login_cmd_postgres -c "ALTER USER customer WITH PASSWORD '$RW_PWD';"



