
CREATE TABLE contract_instances (
    instance_pk         SERIAL PRIMARY KEY,
    instance_id         VARCHAR(256),
    contract_id         VARCHAR(256) NOT NULL,
    instance_state      BYTEA,
    event_stream_id             VARCHAR(40) NOT NULL,
    event_stream_current_index  BIGINT,
    created_account_id  VARCHAR(256) NOT NULL,
    created_user_id     VARCHAR(256) NOT NULL,
    created_request_id  VARCHAR(256),
    created_subscription_id  VARCHAR(256)
);

CREATE UNIQUE INDEX indxUniqInstanceId
    ON contract_instances(instance_id);

-----------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.0',
        updated = now();