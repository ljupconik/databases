bitcoin_networks = ['regtest', 'testnet', 'mainnet']
environments = ['dev', 'qa', ,'nft','stag', 'prod', 'demo']
databases = ['eventstream', 'customer', 'funding', 'smartcontracts', 'billing', 'sars']
backup_snapshot = ['0', '1']

pipeline {
    agent {
        kubernetes {
            defaultContainer 'dbconfig'
            idleMinutes 1
            yamlFile 'KubernetesPod.yml'
        }
    }
    parameters {
            choice(name: 'BTC_NETWORK', choices: bitcoin_networks, description: 'Select the deployment Bitcoin Network')
            choice(name: 'DEPLOYMENT_ENVIRONMENT', choices: environments, description: 'Select the environment type')
            choice(name: 'DB_NAME', choices: databases, description: 'Select the database')
            choice(name: 'DB_SNAPSHOT', choices: backup_snapshot, description: 'Create DB Backup Snapshot, before any destructive script runs ?')
            choice(name: 'VERSION_TYPE', choices: ['APP_VERSION', 'DB_VERSION'], description: 'Use DB_VERSION or APP_VERSION ???')
            string(name: 'APP_VERSION', defaultValue: '', trim: true, description: 'OPTIONAL: APP_VERSION to lookup DB_VERSION to be deployed')
            string(name: 'DB_VERSION', defaultValue: 'LATEST', trim: true, description: 'OPTIONAL: Which DB_VERSION to deploy')
            string(name: 'AFTER_SCRIPT', defaultValue: 'NONE', trim: true, description: 'OPTIONAL: Additional Script ( ordered comma separated multiple Scripts ) to run ???')
            string(name: 'DROP_CREATE_DB_SCRIPT', defaultValue: 'NONE', trim: true, description: 'OPTIONAL: Script that DROPS and creates an empty DB ???')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins-aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-key-id')
        AWS_DEFAULT_REGION = "eu-west-1"
    }
    stages {
        stage ("Deploy") {
            steps {
                script {
                    withCredentials([string(credentialsId: "ps-db-${DEPLOYMENT_ENVIRONMENT}", variable: 'PG_PASSWORD'),
                                     string(credentialsId: "ps-db-${DEPLOYMENT_ENVIRONMENT}-rw", variable: 'RW_PWD'),
                                     string(credentialsId: "ps-db-${DEPLOYMENT_ENVIRONMENT}-ro", variable: 'RO_PWD')
                    ]) {
                        sh "chmod +x ./deploy_db.sh"
                        sh '''
                           set +o posix
                           #set +x
                           set -xv

                           export RW_PWD
                           export RO_PWD

                           echo "VERSION_TYPE=${VERSION_TYPE}"
                           echo "APP_VERSION=${APP_VERSION}"
                           [[ "$VERSION_TYPE" == "DB_VERSION" ]] && echo "DB_VERSION=${DB_VERSION}"

                           source ./functions.sh
                           declare -a array_databases_with_app_versions=("eventstream" "funding" "smartcontracts" "billing" "sars")

                           if elementIn "$DB_NAME" "${array_databases_with_app_versions[@]}"
                           then
                             if ! all_unique_app_versions "$DB_NAME" ; then exit 1; fi;
                             if ! all_db_versions_exist "$DB_NAME" ; then exit 1; fi;
                           fi

                           if ! all_filename_db_versions_conform "$DB_NAME" ; then exit 1; fi;


                           cmd="./deploy_db.sh -p ${PG_PASSWORD} -d ${DB_NAME} -n ${BTC_NETWORK} -e ${DEPLOYMENT_ENVIRONMENT} -s ${DB_SNAPSHOT}"

                           if [[ "$VERSION_TYPE" == "DB_VERSION" ]]
                           then
                                [[ "$DB_VERSION" != "LATEST" ]] && cmd="${cmd} -v ${DB_VERSION}"
                           elif [[ "$VERSION_TYPE" == "APP_VERSION" ]]
                           then
                                if [[ -z "$APP_VERSION" ]]
                                      then
                                         echo -en "\nERROR: No APP_VERSION has been specified\n"
                                         exit 2
                                      else
                                         DB_VERSION=$(get_dbversion_from_appversion "${DB_NAME}" "${APP_VERSION}")
                                         echo "derived DB_VERSION=${DB_VERSION}"
                                         cmd="${cmd} -v ${DB_VERSION}"
                                      fi
                           else
                                echo "VERSION_TYPE can only be 'DB_VERSION' or 'APP_VERSION'"
                                exit 1
                           fi

                           ### remove any whitespaces from AFTER_SCRIPT
                           AFTER_SCRIPT="$(echo -e "${AFTER_SCRIPT}" | tr -d '[:space:]')"

                           [[ "$AFTER_SCRIPT" != "NONE" ]] && cmd="${cmd} -a ${AFTER_SCRIPT}"
                           [[ "$DROP_CREATE_DB_SCRIPT" != "NONE" ]] && cmd="${cmd} -r ${DROP_CREATE_DB_SCRIPT}"

                           echo $cmd
                           $cmd
                           '''
                    }
                }
            }
        }
    }
}
