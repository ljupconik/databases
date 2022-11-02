#!/bin/bash
set +o posix
##set -xv

source ./functions.sh

usage() {
  echo -en "\nUsage: $0 -d DBNAME  [ -p PG_PASSWORD ] [ -a AFTER_SCRIPT ] [ -r DROP_CREATE_DB_SCRIPT ] [ -v UPTO_DB_VERSION ]

  Required parameters:

-d ,   Name of the database which SQL versions will be deployed, must be one of (billing, customer, eventstream, funding, smartcontracts, sars)

  Optional parameters:

-p ,   Password of the postgres admin user
-a ,   Name of a script(s) ( ordered comma separated multiple Scripts ) that can be found in the 'DBNAME/after' folder to run after any DB_VERSIONS
-r ,   Name of the optional Template script that drops and recreates the DBNAME
-v ,   Specific Database Version to upgrade to ( If omitted upgrades to the LATEST available DB version ) , e.g. 1.6

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

unset PG_PASSWORD DBNAME AFTER_SCRIPT DROP_CREATE_DB_SCRIPT UPTO_DB_VERSION

while getopts 'd:p:a:r:v:' c
do
  case $c in
    d) set_variable DBNAME "$OPTARG" ;;
    p) set_variable PG_PASSWORD "$OPTARG" ; [[ -z "$PG_PASSWORD" ]] && usage ;;
    a) set_variable AFTER_SCRIPT "$OPTARG" ; [[ -z "$AFTER_SCRIPT" ]] && usage ;;
    r) set_variable DROP_CREATE_DB_SCRIPT "$OPTARG" ; [[ -z "$DROP_CREATE_DB_SCRIPT" ]] && usage ;;
    v) set_variable UPTO_DB_VERSION "$OPTARG" ; [[ -z "$UPTO_DB_VERSION" ]] && usage ; if ! db_version_is_digit_dot_digit "$UPTO_DB_VERSION" ; then usage ; fi; ;;
    ?) usage ;; esac
done
shift $((OPTIND-1))

[[ -z "$DBNAME" ]] && usage;  if ! elementIn "$DBNAME" "${array_databases[@]}"; then usage ; fi;

cmd="./deploy_db.sh -n DOCKER -e DOCKER -s 0 -d ${DBNAME} "

[[ ! -z "$PG_PASSWORD" ]] && cmd="${cmd} -p ${PG_PASSWORD}"
[[ ! -z "$AFTER_SCRIPT" ]] && cmd="${cmd} -a ${AFTER_SCRIPT}"
[[ ! -z "$DROP_CREATE_DB_SCRIPT" ]] && cmd="${cmd} -r ${DROP_CREATE_DB_SCRIPT}"
[[ ! -z "$UPTO_DB_VERSION" ]] && cmd="${cmd} -v ${UPTO_DB_VERSION}"

#echo $cmd
$cmd