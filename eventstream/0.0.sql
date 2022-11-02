REVOKE CREATE, USAGE ON SCHEMA public FROM PUBLIC;

DROP USER if exists eventstream;
CREATE USER eventstream WITH
    PASSWORD '<rw-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO eventstream;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO eventstream;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO eventstream;


DROP USER if exists eventstream_ro;
CREATE USER eventstream_ro WITH
    PASSWORD '<ro-pwd>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO eventstream_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO eventstream_ro;

--------------------------------------------------------------------------------------------

CREATE TABLE db_version AS
    SELECT '0.0' AS current_version, now() as updated;