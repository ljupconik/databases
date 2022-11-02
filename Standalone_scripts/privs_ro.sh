#!/bin/bash
set +o posix
set -xv

source ../functions.sh


$login_cmd_dbname -c "GRANT USAGE ON SCHEMA public TO ${DBNAME}_ro;"

$login_cmd_dbname -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${DBNAME}_ro;"

$login_cmd_dbname -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ${DBNAME}_ro;"