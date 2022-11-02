#!/bin/bash
set +o posix
set +x
###set -xv

source ../functions.sh



###$login_cmd_dbname -c "SELECT current_version FROM $DB_VERSION_TABLENAME"
if [[ "$DBNAME" == "customer" ]]; then
  $login_cmd_dbname -c "insert into api_key
  (api_key, account_id, subscription_id, contact_ps_user_id, key_active, created_by)
  values
  ('asd34fQWbzasdvFzHTmEtXEmYhasdPh7CXWiFrdj', 1, 1, 1, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9')
    ON CONFLICT (api_key) DO NOTHING;";
else
  echo -en "\n-------- This script can only be run for DBNAME=customer --------\n\n"
  exit 9
fi;