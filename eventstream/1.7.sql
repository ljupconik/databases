
ALTER TABLE EventBlockchainData 
	ADD COLUMN blockchainDataIdPrev BIGINT,
	ADD CONSTRAINT eventBlockchainDataIdPrev_fkey 
		FOREIGN KEY (blockchainDataIdPrev) REFERENCES BlockchainData(blockchainDataId);



ALTER TABLE BlockchainData 
	ADD COLUMN blockchainDataIdPrev BIGINT,
	ADD CONSTRAINT blockchainDataIdPrev_fkey 
		FOREIGN KEY (blockchainDataIdPrev) REFERENCES BlockchainData(blockchainDataId);

CREATE TABLE RequestIdempotency (
      idempotencyToken          VARCHAR(256),
      nr                        INT,
      PRIMARY KEY(idempotencyToken, nr),

      createdAt                 TIMESTAMP NOT NULL,

      eventStreamId             BIGINT,
      eventId                   BIGINT,

      requestDigest             VARCHAR(256),

      FOREIGN KEY (eventId) REFERENCES Event (eventId),
      FOREIGN KEY (eventStreamId) REFERENCES EventStream (eventStreamId)
    );

----------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.7',
        updated = now();