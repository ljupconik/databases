#!/bin/bash
#set -xv
set +x
set +o posix

source ./functions.sh


for DB_NAME in "${array_databases[@]}"
do
  if ! all_filename_db_versions_conform "$DB_NAME" ; then exit 1; fi;
done


declare -a array_databases_with_app_versions=("eventstream" "funding" "smartcontracts" "billing" "sars")

for DB_NAME in "${array_databases_with_app_versions[@]}"
do
  if ! all_unique_app_versions "$DB_NAME" ; then exit 1; fi;
  if ! all_db_versions_exist "$DB_NAME" ; then exit 1; fi;
done

echo -en "\n\n--------- All APP and DB Version Checks have passed successfully ---------\n\n"