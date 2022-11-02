REVOKE CREATE, USAGE ON SCHEMA public FROM PUBLIC;

DROP USER if exists customer;
CREATE USER customer WITH
    PASSWORD '<rw-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO customer;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO customer;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO customer;


DROP USER if exists customer_ro;
CREATE USER customer_ro WITH
    PASSWORD '<ro-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO customer_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO customer_ro;

--------------------------------------------------------------------------------------------

CREATE TABLE db_version AS
    SELECT '0.0' AS current_version, now() as updated;