#!/bin/bash
set +o posix
##set -xv

source ../functions.sh

usage() {
  echo -en "\nUsage: $0 -p PG_PASSWORD -d DBNAME -n NETWORK -e ENVIRONMENT -r RUN_SCRIPT

  Required parameters:

-d ,   Name of the database which SQL versions will be deployed, must be one of (billing, customer, eventstream, funding, smartcontracts)
-n ,   Bitcoin network name ( regtest , testnet , mainnet ... )
-e ,   Environment (dev , qa ... )
-r ,   name of script in folder Standalone_scripts to run

  Optional parameters:

-p ,   Password of the postgres admin user


  "
  exit 1
}

set_variable() {
  local varname=$1
  shift
  if [ -z "${!varname}" ]; then
    eval "$varname=\"$@\""
  else
    echo "Error: $varname already set"
    usage
  fi
}

#########################
# Main script starts here

unset DBNAME NETWORK ENVIRONMENT RUN_SCRIPT PG_PASSWORD

while getopts 'd:n:e:r:p:' c
do
  case $c in
    d) set_variable DBNAME "$OPTARG" ;;
    n) set_variable NETWORK "$OPTARG" ;;
    e) set_variable ENVIRONMENT "$OPTARG" ;;
    r) set_variable RUN_SCRIPT "$OPTARG" ;;
    p) set_variable PG_PASSWORD "$OPTARG" ; [[ -z "$PG_PASSWORD" ]] && usage ;;
    ?) usage ;; esac
done
shift $((OPTIND-1))


[[ -z "$DBNAME" ]] && usage;  if ! elementIn "$DBNAME" "${array_databases[@]}"; then usage ; fi;
[[ -z "$NETWORK" ]] && usage
[[ -z "$ENVIRONMENT" ]] && usage
[[ -z "$RUN_SCRIPT" ]] && usage



DB_INSTANCE_IDENTIFIER="ps-$ENVIRONMENT-$NETWORK-$DBNAME"

if [[ "$NETWORK" == "DOCKER" && "$ENVIRONMENT" == "DOCKER" ]]
then
  DB_HOSTNAME='localhost'
else
  DB_HOSTNAME=$( aws rds describe-db-instances --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" --query 'DBInstances[0].[Endpoint.Address]' --output text )
  [ $? -ne 0 ] && echo "DB_HOSTNAME cannot be found for  DB_INSTANCE_IDENTIFIER=$DB_INSTANCE_IDENTIFIER" && exit 2;
  echo -en "\n-------- DB_HOSTNAME=$DB_HOSTNAME -------- \n\n"
fi

export PGPASSWORD=$PG_PASSWORD

login_cmd_postgres="psql -v ON_ERROR_STOP=1 -h $DB_HOSTNAME -U postgres"
login_cmd_dbname="$login_cmd_postgres -d $DBNAME"

export login_cmd_postgres
export login_cmd_dbname
export DBNAME
export ENVIRONMENT

./"$RUN_SCRIPT"

