CREATE INDEX ix_txos_lookup ON txos(reservedat, alias, spendingtxid, derivationpath);

--comment:Create derivation path counter.
CREATE TABLE derivation_path_counter(
    alias TEXT PRIMARY KEY
    ,indexCounter   BIGINT NOT NULL
    ,updatedAt      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO derivation_path_counter(alias, indexCounter)
VALUES('ps_signer',0),
      ('ps_topup',0);

CREATE TABLE unspent_change(
     lockingscript TEXT PRIMARY KEY
    ,alias TEXT
    ,derivationPath TEXT
    ,createdAt      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.1',
        updated = now();