SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '<db_name>';

DROP DATABASE IF EXISTS <db_name>;

CREATE DATABASE <db_name>
    WITH
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    CONNECTION LIMIT = -1;