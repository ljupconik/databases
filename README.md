# Overview
## Database Versioning
This repository  contains the all the PS databases ( SMARTCONTRACTS , FUNDING , EVENTSTREAM, CUSTOMER , BILLING ) deployment scripts. Each database has it own folder with the same name containing the SQL files that are named by the DB_VERSION they represent. Each next version must be an increment of '0.1'. The DB_VERSIONS must be made up of only 1 digit major number and only 1 digit of minor number. Once the minor number gets to 9 , the following version should increment the major number by 1 and set the minor to 0  ('1.9' -> '2.0').

Also please make sure when adding a new ${DB_VERSION}.sql  file that the last line in the file is :

```
UPDATE db_version
    SET current_version = '{DB_VERSION}',
        updated = now();
```

## Application to Database version mapping
Each Database that has its own Application/Service contains a file named '{DB_NAME}/app_to_db_versions'. This file contains the mapping of each Application version to its corresponding latest working Database version APP_VERSION=DB_VERSION  ( 0.0.16=1.7 ).

Those databases that don’t have their own Application/Service , such as the Customer DB , for the time being are deployed by their LATEST  DB_VERSION.  ( If anyone has any suggestion , please write in the comments bellow , or send an email to l.nikolov@nchain.com )

The first column in '{DB_NAME}/app_to_db_versions' , which is the APP_VERSION is basically a PRIMARY KEY. So each APP_VERSION can exist only once in this file. Each DB_VERSION must have an existing correspondingly named ${DB_VERSION}.sql  file.

To successfully deploy an APP_VERSION for ( SMARTCONTRACTS , FUNDING , EVENTSTREAM ) , there must be a matching line in its  '{DB_NAME}/app_to_db_versions'  with that APP_VERSION.  At Deployment time the DB_VERSION to be deployed in its database is derived from this file providing the APP_VERSION as an input parameter.

When making a change for a particular Database/Application please create a new branch named $DB_NAME-$VERSION and a pull request in to master.



## Deploy Database in a local Docker container
First make sure you have the Docker daemon running on you PC.

Once the desired branch is checked out on your local PC from  https://bitbucket.org/nchteamnch/databases  git repository, that contains all the PS databases ( SMARTCONTRACTS , FUNDING , EVENTSTREAM, CUSTOMER , BILLING ), regardless  of whether you work on Windows or Linux , the following steps can be run to deploy any of its database in  a local Docker container , so that development of the corresponding application can be simplified


Create a local Docker image based on dockerhub’s  postgres:12.5-alpine  by running the following commands that reads the Dockerfile in the databases folder , copies and prepares all the files from the locally checked out branch into the just created docker image named   pg_image:latest

```
cd databases
docker build -t pg_image .
```

2. Create a running docker container named pg_container  from the just created docker image, that will have a running Postgresql database engine version 12.5 , listening on its default port  5432/tcp

```
docker run -it -p 5432:5432 --name pg_container -d pg_image
```

3. Run the DeployDatabaseDocker.sh  script from within your running docker container to deploy the desired ${DB_NAME}  which must be one of  (billing, customer, eventstream, funding, smartcontracts) , to its LATEST available DB version

```
docker exec -it pg_container ./DeployDatabaseDocker.sh -d ${DB_NAME} -r DB_Drop_Create_Template.sql
```


./DeployDatabaseDocker.sh  has the following usage:

```
./DeployDatabaseDocker.sh -d DBNAME  [ -p PG_PASSWORD ] [ -a AFTER_SCRIPT ] [ -r DROP_CREATE_DB_SCRIPT ] [ -v UPTO_DB_VERSION ]

Required parameters:

-d ,   Name of the database which SQL versions will be deployed, must be one of (customer, eventstream, funding, smartcontracts, billing)

Optional parameters:

-p ,   Password of the postgres admin user
-a ,   Name of a script(s) ( ordered comma separated multiple Scripts ) that can be found in the 'DBNAME/after' folder to run after any DB_VERSIONS
-r ,   Name of the optional Template script that drops and recreates the DBNAME
-v ,   Specific Database Version to upgrade to ( If omitted upgrades to the LATEST available DB version ) , e.g. 1.6
```

NOTE:  if working on Linux , one can also run :
```
./DeployDatabaseDocker.sh -d ${DB_NAME} -r DB_Drop_Create_Template.sql
```