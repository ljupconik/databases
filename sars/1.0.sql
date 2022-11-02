CREATE TABLE txs(
    tx_id text NOT NUll,
    account_id text NOT NUll,
    ps_user_id text NOT NUll,
    request_id text NOT NUll,
    subscription_id text NOT NUll,
    s3_path text NOT NULL,
    size int NOT NULL,
    rendezvous_id text,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tx_id)
);

CREATE TABLE payloads(
    tx_id text NOT NUll,
    account_id text NOT NUll,
    size int NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tx_id) REFERENCES txs(tx_id),
    PRIMARY KEY (tx_id)
);

CREATE TABLE proofs(
    tx_id text NOT NULL,
    blockhash TEXT NOT NULL,
    account_id text NOT NULL,
    size int NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tx_id,  blockhash),
    FOREIGN KEY (tx_id) REFERENCES txs(tx_id)
);

-----------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.0',
        updated = now();