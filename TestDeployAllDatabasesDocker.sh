#!/bin/bash

##set -xv
set +x
set +o posix

source ./functions.sh

for DB_NAME in "${array_databases[@]}"
do
  ./DeployDatabaseDocker.sh -d "$DB_NAME" -r DB_Drop_Create_Template.sql || exit 9
  if [[ "$DB_NAME" == "customer" ]]
  then
    ./DeployDatabaseDocker.sh -d "$DB_NAME" -a StagingProdData.sql,StagingProdESNotarise.sql,apiKeyNonProd.sql,apiKeyProd.sql || exit 9
  fi
done


echo -en "\n\n--------- All Smoke Test Databases Deployments have passed successfully ---------\n\n"