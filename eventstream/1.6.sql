
ALTER TABLE BlockchainData ADD COLUMN txBuildTime TIMESTAMP NOT NULL DEFAULT (NOW() at time zone 'utc');
ALTER TABLE BlockchainData ALTER COLUMN txBuildTime DROP DEFAULT;

ALTER TABLE eventStream RENAME COLUMN maxMessageLength TO wacMaxEventLength;

ALTER TABLE EventStream ADD COLUMN createSubscriptionId VARCHAR(256);

--------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.6',
        updated = now();