ALTER TABLE contract_instances
	ADD labels TEXT[] NOT NULL DEFAULT '{}';

CREATE INDEX
    ON contract_instances
    USING gin(labels);

--------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.5',
        updated = now();
