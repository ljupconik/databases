ALTER TABLE contract_instances
    ALTER COLUMN event_stream_id TYPE varchar(256);

--------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.2',
        updated = now();
