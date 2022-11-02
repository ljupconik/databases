#!/bin/bash
#set -xv

declare -a array_databases=("billing" "customer" "eventstream" "funding" "sars" "smartcontracts")

function get_dbversion_from_appversion() {
   database_name=$1
   application_version=$2
   dbversion_equals_appversion=$(grep "${application_version}=" "${database_name}/app_to_db_versions"  || true)
   database_version=$(echo "${dbversion_equals_appversion}"  | cut -d "=" -f2 | xargs | sed 's/\r$//' )
   if [[ -z "$database_version" ]]
   then
      echo -en "\n\nAPP_VERSION=${application_version} , cannot be found in file ${database_name}/app_to_db_versions\n\n"
      exit 2
   else
      echo "${database_version}"
   fi
}


elementIn () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

get_all_existing_filename_db_versions () {
  database_name=$1

  file_db_versions=()
  for file in $(ls "$database_name"/*.sql)
  do
    file_db_versions+=( "$(basename "$file" .sql)" )
  done
  echo "${file_db_versions[@]}"
}


function all_db_versions_exist() {
  database_name=$1

  all_existing_filename_db_versions=( $( get_all_existing_filename_db_versions "$database_name") )

  non_existing_db_versions=()
  for check_db_version in $(cat "$database_name"/app_to_db_versions | cut -d "=" -f2 | sed 's/\r$//' | sort | uniq )
  do
      if elementIn "$check_db_version" "${all_existing_filename_db_versions[@]}"
      then
        continue
      else
        non_existing_db_versions+=( "$check_db_version" )
      fi
  done

  if [ "${#non_existing_db_versions[@]}" -gt 0 ]
  then
    echo -en "\n\nERROR - The specified db_versions in file '$database_name/app_to_db_versions' DO NOT EXIST :\n\n"
    for non_existing_db_version in ${non_existing_db_versions[@]}; do echo "DB_VERSION=$non_existing_db_version does not exist"; done
    return 1
  else
    return 0
  fi
}


function all_unique_app_versions() {
  database_name=$1
  version_file="$database_name/app_to_db_versions"
  declare -A hashmap=()
  while read count app_version; do [ ${count} -gt 1 ] && hashmap["$app_version"]="$count"; done < <( cat "$version_file" | cut -d '=' -f1 | sort | uniq -c | sort -nr )
  if [ "${#hashmap[@]}" -gt 0 ]
  then
    echo -en "\n\nERROR - The following app_versions in file $version_file are NOT UNIQUE :\n\n"
    for key in ${!hashmap[@]}; do echo "APP_VERSION=$key exists ${hashmap["$key"]} times"; done
    return 1
  else
    return 0
  fi
}

function db_version_is_digit_dot_digit() {
  database_version_to_check=$1
  if echo "$database_version_to_check" | grep -qE '^[0-9]\.[0-9]$'
  then
    return 0
  else
    echo -en "\n\nERROR: DB_VERSION=$database_version_to_check does not conform to convention DIGIT.DIGIT (e.g. '1.7', '8.9')\n"
    return 1
  fi
}

function all_filename_db_versions_conform() {
  database_name=$1
  all_existing_filename_db_versions_for_database=( $( get_all_existing_filename_db_versions "$database_name") )

  for existing_filename_db_version in "${all_existing_filename_db_versions_for_database[@]}"
  do
    if ! db_version_is_digit_dot_digit "$existing_filename_db_version"
    then
      echo -en "\nERROR: filename ${database_name}/${existing_filename_db_version}.sql does not conform to convention DIGIT.DIGIT.sql (e.g. '1.7.sql', '8.9.sql')\n"
      return 1
    else
      continue
    fi
  done

  return 0
}