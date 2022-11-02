#!/bin/bash
set +o posix
##set -xv

source ./functions.sh

usage() {
  echo -en "\nUsage: $0 -s 0|1 -p PG_PASSWORD -d DBNAME -n NETWORK -e ENVIRONMENT [ -a AFTER_SCRIPT ] [ -r DROP_CREATE_DB_SCRIPT ] [ -v UPTO_DB_VERSION ]

  Required parameters:

-s ,   (1) - Create a DB_SNAPSHOT before and if any DDL or DML  SQL is executed , (0) - Don't create any DB_SNAPSHOT
-d ,   Name of the database which SQL versions will be deployed, must be one of (billing, customer, eventstream, funding, smartcontracts, sars)
-n ,   Bitcoin network name ( regtest , testnet , mainnet ... )
-e ,   Environment (dev , qa ... )

  Optional parameters:

-p ,   Password of the postgres admin user
-a ,   Name of a script(s) ( ordered comma separated multiple Scripts ) that can be found in the 'DBNAME/after' folder to run after any DB_VERSIONS
-r ,   Name of the optional Template script that drops and recreates the DBNAME ( not to be used in PRODUCTION )
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

unset DB_SNAPSHOT PG_PASSWORD DBNAME ENVIRONMENT NETWORK AFTER_SCRIPT DROP_CREATE_DB_SCRIPT UPTO_DB_VERSION

while getopts 's:d:n:e:p:a:r:v:' c
do
  case $c in
    s) set_variable DB_SNAPSHOT "$OPTARG" ;;
    d) set_variable DBNAME "$OPTARG" ;;
    n) set_variable NETWORK "$OPTARG" ;;
    e) set_variable ENVIRONMENT "$OPTARG" ;;
    p) set_variable PG_PASSWORD "$OPTARG" ; [[ -z "$PG_PASSWORD" ]] && usage ;;
    a) set_variable AFTER_SCRIPT "$OPTARG" ; [[ -z "$AFTER_SCRIPT" ]] && usage ;;
    r) set_variable DROP_CREATE_DB_SCRIPT "$OPTARG" ; [[ -z "$DROP_CREATE_DB_SCRIPT" ]] && usage ;;
    v) set_variable UPTO_DB_VERSION "$OPTARG" ; [[ -z "$UPTO_DB_VERSION" ]] && usage ; if ! db_version_is_digit_dot_digit "$UPTO_DB_VERSION" ; then usage ; fi; ;;
    ?) usage ;; esac
done
shift $((OPTIND-1))

[[ -z "$DB_SNAPSHOT" ]] && usage;  [[ "$DB_SNAPSHOT" == "0" || "$DB_SNAPSHOT" == "1" ]] || usage
[[ -z "$DBNAME" ]] && usage;  if ! elementIn "$DBNAME" "${array_databases[@]}"; then usage ; fi;
[[ -z "$ENVIRONMENT" ]] && usage
[[ -z "$NETWORK" ]] && usage


DB_INSTANCE_IDENTIFIER="ps-$ENVIRONMENT-$NETWORK-$DBNAME"

if [[ "$NETWORK" == "DOCKER" && "$ENVIRONMENT" == "DOCKER" ]]
then
  DB_HOSTNAME='localhost'
else
  DB_HOSTNAME=$( aws rds describe-db-instances --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" --query 'DBInstances[0].[Endpoint.Address]' --output text )
  [ $? -ne 0 ] && echo "DB_HOSTNAME cannot be found for  DB_INSTANCE_IDENTIFIER=$DB_INSTANCE_IDENTIFIER" && exit 2;
  echo -en "\n-------- DB_HOSTNAME=$DB_HOSTNAME -------- \n\n"
fi
##########################
# DB Changes start here

export PGPASSWORD=$PG_PASSWORD

login_cmd_postgres="psql -v ON_ERROR_STOP=1 -h $DB_HOSTNAME -U postgres"
login_cmd_dbname="$login_cmd_postgres -d $DBNAME"

if [[ ! -z $( $login_cmd_postgres -Atqc '\list '"'""$DBNAME""'" ) ]]
then
  DB_VERSION_TABLENAME='db_version'
  DB_VERSION_TABLENAME_EXISTS=$( $login_cmd_dbname -c 'select 1 from pg_tables where tablename='"'""$DB_VERSION_TABLENAME""'"' and schemaname='"'public'" -t | xargs )
fi

if [ -z "$DB_VERSION_TABLENAME_EXISTS" ]; then
  DB_VERSION=0;
else
  DB_VERSION=$( $login_cmd_dbname -c "SELECT current_version FROM $DB_VERSION_TABLENAME" -t | xargs )
fi

echo -en "\n-------- DBNAME=$DBNAME is at DB_VERSION=$DB_VERSION -------- \n\n"


filename_db_versions=( $( get_all_existing_filename_db_versions "$DBNAME") )
echo -en "filename_db_versions=[${filename_db_versions[@]}] \n\n"

if [[ ! -z "$UPTO_DB_VERSION" ]]; then
  if ! elementIn "$UPTO_DB_VERSION" "${filename_db_versions[@]}"; then
    echo -en "\n\nError : Desired DB_VERSION=v$UPTO_DB_VERSION does not exist \n\n"
    exit 4
  fi
fi


TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
unset DB_SNAPSHOT_DONE DB_SNAPSHOT_ID

DB_VERSION_WITH_MINUS=$(echo $DB_VERSION | sed "s/\./\-/")

create_db_snapshot()
{
  if [[ "$DB_SNAPSHOT" == "1" ]]
  then
    DB_SNAPSHOT_ID="$DB_INSTANCE_IDENTIFIER-dbver-$DB_VERSION_WITH_MINUS-timestamp-$TIMESTAMP"
    if aws rds create-db-snapshot --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" --db-snapshot-identifier "$DB_SNAPSHOT_ID"
    then
      aws rds wait db-snapshot-completed --db-snapshot-identifier "$DB_SNAPSHOT_ID"
      echo -en "\n-------- DB_SNAPSHOT_ID=$DB_SNAPSHOT_ID created successfully --------\n\n"
      DB_SNAPSHOT_DONE=1
    else
      echo "Could not create DB_SNAPSHOT_ID=$DB_SNAPSHOT_ID"
      exit 9
    fi
  fi
}



if [ ! -z "$DROP_CREATE_DB_SCRIPT" ]; then
  if [[ -f "$DROP_CREATE_DB_SCRIPT" ]] ; then
    [[ -z "$DB_SNAPSHOT_DONE" ]] && create_db_snapshot
    echo -en "Running DROP_CREATE_DB_SCRIPT=$DROP_CREATE_DB_SCRIPT for DBNAME=$DBNAME \n\n"
    cat "$DROP_CREATE_DB_SCRIPT" | sed "s/<db_name>/$DBNAME/g" | $login_cmd_postgres -f -    &&  DB_VERSION=0  ||  exit 8
  else
    echo "DROP_CREATE_DB_SCRIPT=$DROP_CREATE_DB_SCRIPT cannot be found"
    exit 3
  fi
fi


INFINITY_DB_VERSION=999999
[[ -z "$UPTO_DB_VERSION" ]] && UPTO_DB_VERSION="$INFINITY_DB_VERSION"
if [[  "$UPTO_DB_VERSION" < "$DB_VERSION"  ]]; then
  echo -en "\n\nError : Desired DB_VERSION=v$UPTO_DB_VERSION must not be less than CURRENT_DBVERSION=v$DB_VERSION\n\n"
  exit 4
else
  [[ "$UPTO_DB_VERSION" != "$INFINITY_DB_VERSION" ]] && echo -en "\n-------- Trying to update DB_VERSION to the specified  v$UPTO_DB_VERSION --------\n\n"
fi;


for file_version in "${filename_db_versions[@]}";
do
  if [[ $file_version > $DB_VERSION ]]; then
      if [[ ! $file_version > $UPTO_DB_VERSION ]]; then
          [[ -z "$DB_SNAPSHOT_DONE" ]] && create_db_snapshot
          sql_file="$DBNAME/$file_version.sql";
          if [[ $file_version == "0.0" ]]; then
              if cat "$sql_file" | sed s/\<rw-pwd\>/"$RW_PWD"/g | sed s/\<ro-pwd\>/"$RO_PWD"/g | ${login_cmd_dbname} -f - ; then
                  JUST_DEPLOYED_VERSION=$file_version
                  continue
              else
                  exit 7;
              fi;
          else
            command_to_run="$login_cmd_dbname -f $sql_file";
          fi;

          echo -en "$command_to_run \n\n";
          $command_to_run  ||  exit 7;

          JUST_DEPLOYED_VERSION=$file_version;
      fi;
  fi;
done


if [ -z "$JUST_DEPLOYED_VERSION" ]; then
  echo -en "\n\n-------- No new DB_VERSION update found for DBNAME=$DBNAME , its DB_VERSION=$DB_VERSION was already up to date --------\n\n"
else
  echo -en "\n-------- DBNAME=$DBNAME , updated to DB_VERSION=$JUST_DEPLOYED_VERSION --------\n\n"
fi




if [ ! -z "$AFTER_SCRIPT" ]; then
  IFS=',' read -ra AFTER_SCRIPTS <<< "$AFTER_SCRIPT"

  for SCRIPT in "${AFTER_SCRIPTS[@]}"
  do
    AFTER_SCRIPT_PATH="$DBNAME/after/$SCRIPT"
    if [[ -f "$AFTER_SCRIPT_PATH" ]] ; then
      after_script_allowed_environments=( $( head -1 "$AFTER_SCRIPT_PATH" | cut -f 3 -d '-' | sed s/\,/\ /g ) )
      if ! elementIn "$ENVIRONMENT" "${after_script_allowed_environments[@]}"; then
        echo -en "\n ERROR : AFTER_SCRIPT=$AFTER_SCRIPT_PATH , selected to be run in ENVIRONMENT='$ENVIRONMENT' , can only be run in ENVIRONMENTS : ${after_script_allowed_environments[@]}  \n\n"
        exit 4
      fi
    else
      echo -en "\nERROR: AFTER_SCRIPT=$AFTER_SCRIPT_PATH cannot be found , EXITING ...\n\n"
      exit 9
    fi
  done

  for SCRIPT in "${AFTER_SCRIPTS[@]}"
  do
    AFTER_SCRIPT_PATH="$DBNAME/after/$SCRIPT"
    echo -en "\nAFTER_SCRIPT_PATH=$AFTER_SCRIPT_PATH\n"
    if [[ -f "$AFTER_SCRIPT_PATH" ]] ; then
      [[ -z "$DB_SNAPSHOT_DONE" ]] && create_db_snapshot

      echo -en "Running AFTER_SCRIPT=$AFTER_SCRIPT_PATH \n\n"
      command_after="$login_cmd_dbname -f $AFTER_SCRIPT_PATH";
      echo -en "$command_after \n\n";
      $command_after ||  exit 8;
    else
      echo -en "\nERROR: AFTER_SCRIPT=$AFTER_SCRIPT_PATH cannot be found , EXITING ...\n\n"
      exit 9
    fi
  done
fi


