
ALTER TABLE EventStream
	ADD COLUMN createMetadata TEXT;

ALTER TABLE EventStream
	ADD COLUMN finaliseMetadata TEXT;

----------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.8',
        updated = now();