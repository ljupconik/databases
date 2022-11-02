CREATE TABLE Open_events (
  openEventId	 VARCHAR(256) NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  eventType VARCHAR(256) NOT NULL,
  modifiers TEXT,
  accountId			BIGINT NOT NULL,
  subscriptionId	BIGINT NOT NULL, 
  dateAggregated TIMESTAMP,
  PRIMARY KEY (openEventId, timestamp)
);

CREATE TABLE Unbilled_usage (
  eventId VARCHAR(256) PRIMARY KEY,
  timeStamp TIMESTAMP NOT NULL,
  accountId BIGINT NOT NULL,
  subscriptionId BIGINT NOT NULL,
  chargeUnit VARCHAR(20) NOT NULL,
  target varchar(256) NOT NULL,
  bsvFee BIGINT,
  qty BIGINT,
  modifiers TEXT,
  dateAggregated TIMESTAMP
);

CREATE TABLE Billed_charges (
  chargeId SERIAL NOT NULL,
  accountId BIGINT NOT NULL,
  subscriptionId BIGINT NOT NULL,
  chargeUnit VARCHAR(20) NOT NULL,
  modifier VARCHAR(30) NOT NULL,
  pricingModel VARCHAR(20) NOT NULL,
  modifierTotalUnits NUMERIC NOT NULL,
  modifierCharge NUMERIC NOT NULL,
  unitOfMeasure VARCHAR(20) NOT NULL, 
  pricePerUnit REAL NOT NULL,
  currencyCode VARCHAR(4) NOT NULL,
  currencyRate REAL NOT NULL,
  discountPercentage REAL NOT NULL,
  invoiceNotes VARCHAR(255),  
  bsvFee BIGINT,
  dateBilled TIMESTAMP,
  PRIMARY KEY (chargeId, accountId, subscriptionId, chargeUnit, modifier, pricingModel)  
);

CREATE INDEX charges ON Billed_charges (accountId) include (subscriptionId, chargeUnit, dateBilled);

CREATE TABLE Chargebee_staging (
  accountId BIGINT NOT NULL,
  chargeItem BIGINT NOT NULL,
  billingAccountId BIGINT NOT NULL,
  chargeDescription TEXT NOT NULL,
  invoiceCurrency VARCHAR(4) NOT NULL,
  invoiceAmount NUMERIC NOT NULL,
  PostedToChargebee TIMESTAMP,
  PRIMARY KEY (accountId, chargeItem)
);

CREATE TABLE Billing_archive (
  accountId BIGINT NOT NULL,
  chargeItem BIGINT NOT NULL,
  billingAccountId BIGINT NOT NULL,
  chargeDescription TEXT NOT NULL,
  invoiceCurrency VARCHAR(4) NOT NULL,
  invoiceAmount NUMERIC NOT NULL,
  billingPeriodStart DATE NOT NULL,
  billingPeriodEnd DATE NOT NULL,
  archivedDate TIMESTAMP NOT NULL,
  PRIMARY KEY (accountId, chargeItem)
);

ALTER TABLE billed_charges ADD COLUMN purchaseOrderId INTEGER;
ALTER TABLE billed_charges ADD COLUMN aggregationDateFrom TIMESTAMP;
ALTER TABLE billed_charges ADD COLUMN aggregationDateTo TIMESTAMP;
ALTER TABLE chargebee_staging ADD COLUMN purchaseOrderId INTEGER;
ALTER TABLE chargebee_staging ADD COLUMN billingPeriodStart TIMESTAMP;
ALTER TABLE chargebee_staging ADD COLUMN billingPeriodEnd TIMESTAMP;
ALTER TABLE billing_archive ADD COLUMN purchaseOrderId INTEGER;

CREATE TABLE Validation_messeges (
  errorId	 INT NOT NULL,
  errorCode VARCHAR(10) NOT NULL,
  errorDescription VARCHAR(256) NOT NULL,
  dateCreated TIMESTAMP,
  createdBy	VARCHAR(30) DEFAULT 'Support Staff',
  dateModified TIMESTAMP, 
  modifiedBy VARCHAR(30),
  PRIMARY KEY (errorId)
);

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(1, 'srcerr1', 'Pricing model UNIT must contain exactly one rate!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(2, 'srcerr2', 'The EndRange must be empty!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(3, 'srcerr3', 'A hybrid pricing model must contain at least two different rates. The first one is for a unit pricing model and the second for a volume pricing model!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(4, 'srcerr4', 'A hybrid pricing model must contain a rate for unit pricing model. This rate must have a property startRange set and a property endRange must be empty!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(5, 'srcerr5', 'A flat fee must have exactly one rate!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(6, 'srcerr6', 'StartRange and endRange fields for a flat fee pricing model must be empty!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(7, 'srcerr7', 'Modifier and unit of measure of a flat fee pricing model must be set to N/A!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(8, 'srcerr8', 'Start range must be a positive number!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(9, 'srcerr9', 'An appropriate rate for modifierTotalUnits could not be found!', now());

insert into validation_messeges 
(errorId, errorcode, errordescription, datecreated)
values
(10, 'calerr10', 'It appears that the period chosen for the Calculation Step does not align with the period used in prior Aggregation runs', now());


-----------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.1',
        updated = now();