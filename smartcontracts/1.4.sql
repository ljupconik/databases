ALTER TABLE contract_instances
  ADD uncommitted_state      BYTEA,
  ADD uncommitted_expiration TIMESTAMP,
  ADD uncommitted_count INT;

--------------------------------------------------------------------------------------

CREATE TABLE vc_rendezvous (
    rendezvous_pk          BIGSERIAL PRIMARY KEY,
    rid                    VARCHAR(256) NOT NULL,
    instance_id            VARCHAR(256) NULL,
    operation              VARCHAR(256) NOT NULL,
    idempotency_token      VARCHAR(256) NOT NULL,
    created_date           TIMESTAMP NOT NULL,
    rx_valid_until         TIMESTAMP NOT NULL,
    completion_status      BOOLEAN NULL,
    request                BYTEA NOT NULL
);

CREATE UNIQUE INDEX vc_rendezvous_token_rid_instance_id
  ON vc_rendezvous(rid, instance_id);

--------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.4',
        updated = now();
