ALTER TABLE contract_instances
  ADD COLUMN key_context_alias      VARCHAR(256) NOT NULL;

CREATE TABLE vcp_processes (
  process_pk          BIGSERIAL PRIMARY KEY,
  process_public_id   VARCHAR(256) NOT NULL,
  name                VARCHAR(256) NOT NULL,
  is_transient_process   BOOLEAN NOT NULL,
  es_id               VARCHAR(256) NOT NULL,
  publicise_code      BOOLEAN NOT NULL,
  publicise_execution_context BOOLEAN NOT NULL,

  created_account_id  VARCHAR(256) NOT NULL,
  created_user_id     VARCHAR(256) NOT NULL,
  created_subscription_id  VARCHAR(256),
  created_date        TIMESTAMP NOT NULL,

  is_provisioned      BOOLEAN NOT NULL,
  is_in_upgrade       BOOLEAN NOT NULL,
  upgrade_start_time  TIMESTAMP NULL,
  is_enabled          BOOLEAN NOT NULL,
  is_retired          BOOLEAN NOT NULL,
  retired_date        TIMESTAMP NULL
);

CREATE UNIQUE INDEX index_process_public_id
  ON vcp_processes(process_public_id);

CREATE UNIQUE INDEX index_process_name
  ON vcp_processes(name, created_account_id) WHERE is_provisioned = TRUE AND is_retired = FALSE;

CREATE INDEX index_process_list
  ON vcp_processes(created_account_id, process_pk)
  WHERE is_provisioned = TRUE AND is_retired = FALSE;

CREATE TABLE vcp_process_versions (
  version_pk          BIGSERIAL PRIMARY KEY,
  process_pk          BIGINT NOT NULL,
  version             INTEGER NOT NULL,
  target_name         VARCHAR(256) NOT NULL,
  target_version      VARCHAR(256) NULL,

  created_account_id  VARCHAR(256) NOT NULL,
  created_user_id     VARCHAR(256) NOT NULL,
  created_subscription_id     VARCHAR(256),
  created_date        TIMESTAMP NOT NULL,
  is_provisioned      BOOLEAN NOT NULL,
  provisioning_failure_step   VARCHAR(256) NULL,
  provisioning_failure_info   VARCHAR(512) NULL,
  is_active           BOOLEAN NOT NULL,
  activation_date     TIMESTAMP NULL,
  deactivation_date   TIMESTAMP NULL,
  cleanup_date        TIMESTAMP NULL,
  cleanup_failure_info        VARCHAR(512) NULL,
  run_time            VARCHAR(256) NULL,
  entry_function      VARCHAR(256) NULL,
  max_execution_duration        INTEGER NULL,
  memory_limit_mb     INTEGER NULL,
  provisioned_containers       INTEGER NOT NULL,
  max_call_breadth    INTEGER NOT NULL,
  binary_data         BYTEA NOT NULL,
  FOREIGN KEY (process_pk) REFERENCES VCP_PROCESSES (process_pk) ON DELETE NO ACTION
);

CREATE UNIQUE INDEX index_process_version
  ON vcp_process_versions(process_pk, version);

CREATE INDEX index_process_version_inactive
  ON vcp_process_versions(cleanup_date, is_active, is_provisioned, created_date, deactivation_date, version, process_pk)
  WHERE is_active = FALSE AND is_provisioned = FALSE AND cleanup_date IS NULL;

--------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.1',
        updated = now();
