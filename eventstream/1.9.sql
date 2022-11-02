ALTER TABLE EventStream
	ADD COLUMN eventStreamObjectId TEXT;
	
ALTER TABLE BlockchainData
	ADD COLUMN stdFeePaid INT,
	ADD COLUMN dataFeePaid INT;
	
	
----------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.9',
        updated = now();