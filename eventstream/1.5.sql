
CREATE TABLE REvent (
    rEventId                  BIGSERIAL PRIMARY KEY
);

CREATE TABLE EventStream (
  eventStreamId                     BIGSERIAL PRIMARY KEY,
  eventStreamPublicId               VARCHAR(256),

  accountId                         VARCHAR(256) NOT NULL,
  createdUserId                     VARCHAR(256) NOT NULL,
  createRequestId                   VARCHAR(256),

  keyContextAlias                   VARCHAR(256),
  dustValue                         BIGINT,
  status                            INT,
  finaliseRequested                 BOOLEAN,
  destroyRequested                  BOOLEAN,
  seed                              VARCHAR(256),

  createdAt                         TIMESTAMP NOT NULL,
  finalisedUserId                   VARCHAR(256),
  finaliseRequestId                 VARCHAR(256),
  finalisedAt                       TIMESTAMP,

  wacExplicitSequenceEnable         BOOLEAN NOT NULL,
  wacExplicitSequenceGapPolicy      INT,
  wacExplicitSequenceMaxGapSpan     BIGINT,
  wacExplicitSequenceMaxGapWarn     BIGINT ,

  sscMethod                         INT,
  sscInterval                       INT,
  sscIntervalUnit                   INT,
  sscTimeOfDay                      TIMESTAMP,
  sscSuppressCreateMetadata         BOOLEAN,
  sscSuppressFinaliseMetadata       BOOLEAN,

  nextExpectedIndex                 BIGINT,

  wacRestrictedAccessPubKey         VARCHAR(256),
  wacRestrictedAccessExclusive      BOOLEAN,

  sdcMethod                         INT,
  sdcRetentionPolicy                INT,
  sdcSaltNotarisation               BOOLEAN,

  lacRegion                         INT,

  ceSuppress                        BOOLEAN,

  maxMessageLength                  INT,

  tacOpenFrom                       TIMESTAMP,
  tacOpenUntil                      TIMESTAMP,

  nextScheduledRunTime              TIMESTAMP
);


CREATE TABLE Event (
  eventId                   BIGSERIAL PRIMARY KEY,
  index                     BIGINT NOT NULL,
  eventStreamId             BIGINT NOT NULL,
  createdAt                 TIMESTAMP NOT NULL,

  accountId                 VARCHAR(256) NOT NULL,
  createdUserId             VARCHAR(256) NOT NULL,
  appendRequestId           VARCHAR(256),

  status                    INT,

  streamDigest              VARCHAR(256),
  dataB                     BYTEA,
  dataS                     TEXT,
  dataDigest                VARCHAR(256),
  salt                      VARCHAR(256),

  blockchainDataId          BIGINT,
  rEventId                  BIGINT,
  checkpointNow             BOOLEAN,

  tags                      TEXT[] NOT NULL DEFAULT '{}',

  FOREIGN KEY (eventStreamId) REFERENCES EventStream (eventStreamId),
  FOREIGN KEY (rEventId) REFERENCES REvent (rEventId)
);

CREATE INDEX event_tags ON Event USING gin (tags);

CREATE UNIQUE INDEX indxUniqEventIdempotency
  ON Event(index, eventStreamId, dataDigest);

CREATE UNIQUE INDEX indxUniqEventNoSameSequenceNumber
  ON Event(index, eventStreamId);


CREATE TABLE BlockchainData (
  blockchainDataId          BIGSERIAL PRIMARY KEY,

  eventStreamId             BIGINT,

  type                      INT NOT NULL,
  txId                      VARCHAR(256) NOT NULL,
  broadcasted               BOOLEAN NOT NULL,
  changeAddress             VARCHAR(256),
  changeValue               BIGINT,

  FOREIGN KEY (eventStreamId) REFERENCES EventStream (eventStreamId)
);


CREATE TABLE EventBlockchainData (
  eventBlockchainDataId     BIGSERIAL PRIMARY KEY,

  eventId                   BIGINT NOT NULL,
  blockchainDataId          BIGINT NOT NULL,

  FOREIGN KEY (eventId) REFERENCES Event (eventId),
  FOREIGN KEY (blockchainDataId) REFERENCES BlockchainData (blockchainDataId)
);


CREATE TABLE Dust (
  dustId                    BIGSERIAL PRIMARY KEY,

  blockchainDataId          BIGINT NOT NULL,
  eventStreamId             BIGINT,
  eventId                   BIGINT,

  index                     BIGINT NOT NULL,
  derivationPath            VARCHAR(256) NOT NULL,
  scriptPubKey              BYTEA NOT NULL,
  metaData                  BYTEA,

  FOREIGN KEY (eventStreamId) REFERENCES EventStream (eventStreamId),
  FOREIGN KEY (eventId) REFERENCES Event (eventId),
  FOREIGN KEY (blockchainDataId) REFERENCES BlockchainData (blockchainDataId)
);


CREATE TABLE Fund (
  fundId                    BIGSERIAL PRIMARY KEY,

  blockchainDataId          BIGINT NOT NULL,

  txId                      VARCHAR(256) NOT NULL,
  index                     BIGINT NOT NULL,
  value                     BIGINT NOT NULL,
  scriptPubKey              BYTEA NOT NULL,
  alias                     VARCHAR(256) NOT NULL,
  derivationPath            VARCHAR(256) NOT NULL,

  FOREIGN KEY (blockchainDataId) REFERENCES BlockchainData (blockchainDataId)
);

-----------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.5',
        updated = now();