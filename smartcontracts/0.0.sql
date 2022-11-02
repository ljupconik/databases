REVOKE CREATE, USAGE ON SCHEMA public FROM PUBLIC;

DROP USER if exists smartcontracts;
CREATE USER smartcontracts WITH
    PASSWORD '<rw-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO smartcontracts;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO smartcontracts;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO smartcontracts;


DROP USER if exists smartcontracts_ro;
CREATE USER smartcontracts_ro WITH
    PASSWORD '<ro-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO smartcontracts_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO smartcontracts_ro;

--------------------------------------------------------------------------------------------

CREATE TABLE db_version AS
    SELECT '0.0' AS current_version, now() as updated;