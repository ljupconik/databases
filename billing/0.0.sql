REVOKE CREATE, USAGE ON SCHEMA public FROM PUBLIC;

DROP USER if exists billing;
CREATE USER billing WITH
    PASSWORD '<rw-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO billing;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO billing;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO billing;


DROP USER if exists billing_ro;
CREATE USER billing_ro WITH
    PASSWORD '<ro-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO billing_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO billing_ro;

--------------------------------------------------------------------------------------------

CREATE TABLE db_version AS
    SELECT '0.0' AS current_version, now() as updated;