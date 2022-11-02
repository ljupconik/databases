--liquibase formatted sql

--changeset siordish:C1 stripComments:false runOnChange:false splitStatements:false
--comment:Create audit table.
CREATE TABLE audit (
    id BIGSERIAL PRIMARY KEY,
    tablename TEXT NOT NULL,
    username TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action TEXT NOT NULL CHECK (action in ('U','D')),
    oldvalues HSTORE,
    newvalues HSTORE,
    updatedcols TEXT[],
    query TEXT
);

--changeset siordish:C2 stripComments:false runOnChange:false splitStatements:false
--comment:Create audit function.
CREATE OR REPLACE FUNCTION audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.Created := CURRENT_TIMESTAMP;
        NEW.Modified := CURRENT_TIMESTAMP;
        NEW.Instance := 1;

        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (OLD.Created != NEW.Created) THEN
            RAISE EXCEPTION 'Cannot change the Created timestamp.';
        END IF;

        IF (OLD.Instance != NEW.Instance) THEN
            RAISE EXCEPTION 'Only the database can modify the Instance counter.';
        END IF;

        NEW.Modified := CURRENT_TIMESTAMP;
        NEW.Instance := OLD.Instance + 1;

        INSERT INTO Audit (TableName, UserName, Action, OldValues, NewValues, UpdatedCols, Query)
        VALUES (TG_TABLE_NAME::TEXT, CURRENT_USER::TEXT, 'U', HSTORE(OLD.*), HSTORE(NEW.*), AKEYS(HSTORE(NEW.*) - HSTORE(OLD.*)), CURRENT_QUERY());

        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Audit (TableName, UserName, Action, OldValues, Query)
        VALUES (TG_TABLE_NAME::TEXT, CURRENT_USER::TEXT, 'D', HSTORE(OLD.*), CURRENT_QUERY());
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE PLPGSQL;


--changeset siordish:C3 stripComments:false runOnChange:false splitStatements:false
--comment:Create txos table.
CREATE TABLE txos (
     created        TIMESTAMPTZ NOT NULL
    ,modified       TIMESTAMPTZ NOT NULL
    ,instance       INTEGER NOT NULL
    ,txid           CHAR(64) NOT NULL CHECK (LENGTH(txid) = 64)
    ,vout		    BIGINT NOT NULL CHECK (vout >= 0 AND vout < 4294967296)
    ,alias			TEXT NOT NULL
    ,derivationpath TEXT NOT NULL
    ,scriptpubkey   TEXT NOT NULL
    ,satoshis       BIGINT NOT NULL CHECK (satoshis >= 0)
    ,reserveduntil  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
    ,spentat        TIMESTAMPTZ
    ,spendingtxid   CHAR(64) CHECK (LENGTH(txid) = 64)
    ,PRIMARY KEY (txid, vout)
);
--GRANT ALL ON TABLE txos TO ps;
CREATE TRIGGER txos_audit BEFORE INSERT OR UPDATE OR DELETE ON txos FOR EACH ROW EXECUTE PROCEDURE audit();

--------------------------------------------------------------------

--liquibase formatted sql

--changeset jwahab:C1 stripComments:false runOnChange:false splitStatements:false
--comment:Add outpoint column.
ALTER TABLE txos
    ADD COLUMN outpoint TEXT;

--changeset jwahab:C2 stripComments:false runOnChange:false splitStatements:false
--comment:Update outpoint column as primary key with new data (remove old primary key).
UPDATE txos
    SET outpoint = txid || vout
    WHERE outpoint IS NULL;

ALTER TABLE txos
    DROP CONSTRAINT txos_pkey;

ALTER TABLE txos
    ADD PRIMARY KEY (outpoint);

--liquibase formatted sql

--changeset mfletcher:add_reservedat stripComments:false runOnChange:false splitStatements:false
--comment:Add reservedat field to replace reserveduntil.
ALTER TABLE txos
    ADD COLUMN reservedat TEXT;

--changeset mfletcher:drop_reserveduntil stripComments:false runOnChange:false splitStatements:false
--comment:Drop reserved until.
ALTER TABLE txos
    DROP COLUMN reserveduntil;

----------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.0',
        updated = now();