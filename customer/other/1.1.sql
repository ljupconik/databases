--v1.1

REVOKE CREATE, USAGE ON SCHEMA public FROM PUBLIC;

CREATE USER customer WITH
    PASSWORD '<customer-password>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO customer;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public  TO "customer";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "customer";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO customer;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO customer;



CREATE USER ro WITH
    PASSWORD '<ro-password>'
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT USAGE ON SCHEMA public TO ro;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO ro;


--liquibase formatted sql

--changeset bowstave:C0 stripComments:false runOnChange:false splitStatements:false
--comment:Create enum types.
CREATE TYPE account_statuses AS ENUM
('Active','Deactivated','New','Pending','Suspended','Verified');
CREATE TYPE account_types AS ENUM
('Enterprise Customer','Group Owner','Holding Company','Individual','Partner (VAR)', 'Other');
CREATE TYPE contract_statuses AS ENUM
('Active', 'Deactivated', 'New', 'Pending', 'Signed', 'Suspended');
CREATE TYPE purchase_order_statuses AS ENUM
('Approved', 'Checked', 'New', 'Pending', 'Provisioned');
CREATE TYPE subscriptions_statuses AS ENUM
('Active', 'Available', 'Ended', 'Pending', 'Suspended');
CREATE TYPE service_statuses AS ENUM
('Active', 'Archived', 'Available', 'Ended', 'Pending', 'Suspended');
CREATE TYPE contact_types as ENUM
('Billing', 'Business', 'Legal', 'Technical', 'Other');
CREATE TYPE address_types as ENUM
('Billing', 'Contact', 'Customer' );
CREATE TYPE units_of_measure as ENUM
('Request', 'KB', 'MB', 'GB', 'Second', 'Minute', 'Hour', 'Day', 'Month', 'Year');
CREATE TYPE pricing_models as ENUM
('Hybrid', 'Stairstep', 'Tiered', 'Unit', 'Volume');
CREATE TYPE modifiers as ENUM
('api', 'qty', 'duration', 'executionTimeMs', 'pseudoRandomBytes', 'randomBytes', 'responseBytes', 'stateSavedBytes');
CREATE TYPE offer_types as ENUM
('Application', 'Service', 'Solution');
CREATE TYPE verification_types as ENUM
('AML', 'KYB', 'KYC', 'Credit Check', 'None', 'N/A');
CREATE TYPE inactive_reasosns as ENUM
('Discontinued', 'Error', 'Other', 'Not ready');

--changeset bowstave:C1 stripComments:false runOnChange:false splitStatements:false
--comment:Create address table.
CREATE TABLE address
(
	address_id SERIAL PRIMARY KEY,
	address_type address_types NOT NULL,
	address_line_1 VARCHAR(255) NOT NULL,
	address_line_2 VARCHAR(255),
	city VARCHAR(255) NOT NULL,
	county VARCHAR(255),
	postcode VARCHAR(30) NOT NULL,
	country VARCHAR(255),
	telephone VARCHAR(30),
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C2 stripComments:false runOnChange:false splitStatements:false
--comment:Create product_offer table.
CREATE TABLE product_offer
(
	product_offer_id SERIAL PRIMARY KEY,
	product_offer_title VARCHAR(50) NOT NULL,
	offer_type offer_types NOT NULL,
	offer_description VARCHAR(255) NOT NULL,
	effective_from DATE NOT NULL,
	effective_to DATE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C3 stripComments:false runOnChange:false splitStatements:false
--comment:Create customer_account table.
CREATE TABLE customer_account
(
	account_id SERIAL PRIMARY KEY,
	parent_account_id INTEGER REFERENCES customer_account(account_id),
	owner_account_id INTEGER REFERENCES customer_account(account_id),
	introduced_by_id INTEGER REFERENCES customer_account(account_id),
	account_address_id INTEGER REFERENCES address(address_id) NOT NULL,
	customer_id VARCHAR(255) NOT NULL UNIQUE,
	account_type account_types NOT NULL,
	account_status account_statuses NOT NULL,
	account_name VARCHAR(255) NOT NULL,
	verification_type verification_types NOT NULL,
	date_verified DATE,
	bill_payer BOOLEAN NOT NULL DEFAULT true,
	quota_exceeded BOOLEAN NOT NULL DEFAULT false,
	trial_limit INTEGER NOT NULL DEFAULT 0,
	trial_limit_counter INTEGER NOT NULL DEFAULT 0,
	trial_limit_exceeded BOOLEAN NOT NULL DEFAULT false,
	account_manager VARCHAR(255),
	service_delivery_mgr VARCHAR(255),
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C4 stripComments:false runOnChange:false splitStatements:false
--comment:Create contract table.
CREATE TABLE contract
(
	contract_id SERIAL PRIMARY KEY,
	account_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	activate_by_date DATE NOT NULL,
	signed_date DATE,
	expiry_date DATE,
	contract_status contract_statuses NOT NULL,
	signed_contract VARCHAR(255),
	contract_variations TEXT,
	contract_spend_level REAL NOT NULL,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C5 stripComments:false runOnChange:false splitStatements:false
--comment:Create billing table.
CREATE TABLE billing
(
	billing_id SERIAL PRIMARY KEY,
	account_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	bill_payer_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	billing_address_id INTEGER REFERENCES address(address_id) NOT NULL,
	bill_currency VARCHAR(4) NOT NULL,
	bill_vat_number VARCHAR(255) NOT NULL,
	date_deactivated DATE,
	reason_deactivated VARCHAR(255),
	outstanding_balance REAL NOT NULL DEFAULT 0,
	at_risk_amount REAL NOT NULL DEFAULT 0,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C6 stripComments:false runOnChange:false splitStatements:false
--comment:Create purchase_order table.
CREATE TABLE purchase_order
(
	purchase_order_id SERIAL PRIMARY KEY,
	account_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	contract_id INTEGER REFERENCES contract(contract_id) NOT NULL,
	billing_id INTEGER REFERENCES billing(billing_id) NOT NULL,
	order_date DATE NOT NULL,
	order_status purchase_order_statuses NOT NULL,
	approved_date DATE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C7 stripComments:false runOnChange:false splitStatements:false
--comment:Create subscription table.
CREATE TABLE subscription
(
	subscription_id SERIAL PRIMARY KEY,
	account_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	purchase_order_id INTEGER REFERENCES purchase_order(purchase_order_id) NOT NULL,
	billing_id INTEGER REFERENCES billing(billing_id) NOT NULL,
	status subscriptions_statuses NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C8 stripComments:false runOnChange:false splitStatements:false
--comment:Create service_group table.
CREATE TABLE service_group
(
	group_name VARCHAR(50) PRIMARY KEY,
	group_description VARCHAR(255) NOT NULL,
	group_endpoint VARCHAR(255) NOT NULL,
	group_status service_statuses NOT NULL DEFAULT 'Pending',
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C9 stripComments:false runOnChange:false splitStatements:false
--comment:Create service table.
CREATE TABLE service
(
	service_id SERIAL PRIMARY KEY,
	service_name VARCHAR(50) NOT NULL UNIQUE,
	service_description VARCHAR(255) NOT NULL,
	status service_statuses NOT NULL DEFAULT 'Pending',
	service_group_name VARCHAR(50) REFERENCES service_group(group_name) NOT NULL,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C10 stripComments:false runOnChange:false splitStatements:false
--comment:Create service_details table.
CREATE TABLE service_details
(
	service_name VARCHAR(50) REFERENCES service(service_name) NOT NULL,
	modifier modifiers NOT NULL,
	pricing_model pricing_models NOT NULL,
	unit_of_measure units_of_measure NOT NULL,
	inactive BOOLEAN DEFAULT true NOT NULL,
	inactive_reason inactive_reasosns DEFAULT 'Not ready' NOT NULL,
	inactive_date DATE DEFAULT CURRENT_DATE NOT NULL,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255),
	PRIMARY KEY (service_name, modifier, pricing_model)
);

--changeset bowstave:C11 stripComments:false runOnChange:false splitStatements:false
--comment:Create service_rate_card table.
CREATE TABLE service_rate_card
(
	rate_card_id SERIAL PRIMARY KEY,
	product_offer_id INTEGER REFERENCES product_offer(product_offer_id) NOT NULL,
	subscription_id INTEGER REFERENCES subscription(subscription_id) NOT NULL DEFAULT 0,
	service_id INTEGER REFERENCES service(service_id) NOT NULL,
	modifier VARCHAR(30) NOT NULL,
	pricing_model pricing_models NOT NULL,
	unit_of_measure units_of_measure NOT NULL,
	price_per_unit REAL NOT NULL,
	currency_code VARCHAR(4) NOT NULL DEFAULT 'GBP',
	currency_rate REAL NOT NULL DEFAULT 1,
	start_range REAL,
	end_range REAL,
	bsv_tx_fee INTEGER,
	activate_by_date DATE NOT NULL,
	expiry_date DATE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255),
	UNIQUE (product_offer_id, service_id, start_range),
	UNIQUE (subscription_id, service_id, start_range)
);

--changeset bowstave:C12 stripComments:false runOnChange:false splitStatements:false
--comment:Create subscription_service table.
CREATE TABLE subscription_service
(
	subscription_id INTEGER REFERENCES subscription(subscription_id),
	service_id INTEGER REFERENCES service(service_id),
	service_name VARCHAR(50) REFERENCES service(service_name),
	CONSTRAINT subscription_service_pkey PRIMARY KEY (subscription_id, service_id)
);

--changeset bowstave:C13 stripComments:false runOnChange:false splitStatements:false
--comment:Create contact table.
CREATE TABLE contact
(
	contact_id SERIAL PRIMARY KEY,
	reports_to_id INTEGER REFERENCES contact(contact_id),
	account_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	contact_first_name VARCHAR(255) NOT NULL,
	contact_last_name VARCHAR(255) NOT NULL,
	contact_address_id INTEGER REFERENCES address(address_id) NOT NULL,
	contact_mobile_no VARCHAR(30),
	contact_email_address VARCHAR(255) NOT NULL,
	contact_ps_user_id VARCHAR(30) UNIQUE,
	contact_type contact_types NOT NULL,
	primary_contact BOOLEAN DEFAULT false,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C14 stripComments:false runOnChange:false splitStatements:false
--comment:Create role table.
CREATE TABLE role
(
	role_id VARCHAR(30) PRIMARY KEY,
	role_description VARCHAR(255) NOT NULL,
	inactivate_date DATE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C15 stripComments:false runOnChange:false splitStatements:false
--comment:Create terms_and_conditions table.
CREATE TABLE terms_and_conditions
(
	ps_terms_id VARCHAR(30) PRIMARY KEY UNIQUE,
	ps_terms_description VARCHAR(255) NOT NULL,
	active_by_date DATE NOT NULL,
	date_expired DATE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

--changeset bowstave:C16 stripComments:false runOnChange:false splitStatements:false
--comment:Create purchase_order_product_offer table.
CREATE TABLE purchase_order_product_offer
(
	purchase_order_id INTEGER REFERENCES purchase_order(purchase_order_id),
	product_offer_id INTEGER REFERENCES product_offer(product_offer_id),
	CONSTRAINT purchase_order_product_offer_pkey PRIMARY KEY (purchase_order_id, product_offer_id)
);

--changeset bowstave:C17 stripComments:false runOnChange:false splitStatements:false
--comment:Create product_offer_service table.
CREATE TABLE product_offer_service
(
	product_offer_id INTEGER REFERENCES product_offer(product_offer_id),
	service_id INTEGER REFERENCES service(service_id),
	CONSTRAINT product_offer_service_pkey PRIMARY KEY (product_offer_id, service_id)
);

--changeset bowstave:C18 stripComments:false runOnChange:false splitStatements:false
--comment:Create api_key table.
CREATE TABLE api_key
(
	api_key VARCHAR(255) PRIMARY KEY,
	account_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	subscription_id INTEGER REFERENCES subscription(subscription_id) NOT NULL,
	contact_ps_user_id VARCHAR(30),
	key_active BOOLEAN NOT NULL DEFAULT true,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

---------------------------------------------------------------------------

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Event Stream', 'Solution', 'ES-create', '2020-11-23', '2020-11-23' , '2020-11-23', '1', '2020-11-23', '1');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Event Stream', 'Application', 'ES-appendData', '2020-11-22', '2020-11-22' , '2020-11-22', '2', '2020-11-22', '2');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Event Stream', 'Service', 'ES-destroy', '2020-12-22', '2020-12-22' , '2020-12-22', '3', '2020-12-22', '3');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Smart Contracts', 'Application', 'SC-new', '2020-12-22', '2020-12-22' , '2020-12-22', '4', '2020-12-22', '4');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Event Stream', 'Service', 'ES-settlement', '2020-12-22', '2020-12-22' , '2020-12-22', '5', '2020-12-22', '5');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Smart Contracts', 'Service', 'SC-send', '2020-12-22', '2020-12-22' , '2020-12-22', '6', '2020-12-22', '6');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Smart Contracts', 'Solution', 'SC-history', '2020-12-22', '2020-12-22' , '2020-12-22', '7', '2020-12-22', '7');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Smart Contracts', 'Application', 'SC-indexes', '2020-12-22', '2020-12-22' , '2020-12-22', '8', '2020-12-22', '8');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Smart Contracts', 'Application', 'SC-rendezvous', '2020-12-22', '2020-12-22' , '2020-12-22', '9', '2020-12-22', '9');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Event Stream', 'Solution', 'ES-rendezvous', '2020-12-22', '2020-12-22' , '2020-12-22', '10', '2020-12-22', '10');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Event Stream', 'Service', 'ES-queryData', '2020-12-22', '2020-12-22' , '2020-12-22', '11', '2020-12-22', '11');

insert into product_offer
  (product_offer_title, offer_type, offer_description, effective_from, effective_to, date_created, created_by, date_modified, modified_by)
values
  ('Smart Contracts', 'Application', 'SC-call', '2020-12-22', '2020-12-22' , '2020-12-22', '12', '2020-12-22', '12');



insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (1, 'Customer', 'JERVISWOOD', 'NULL', 'London', NULL, 'ML11 0GU', 'United Kingdom', '07923428319', '2020-11-23', '1', '2020-11-23', '1');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (2, 'Contact', 'WHITLAND', 'NULL', 'Southampton', NULL, 'SA34 0TP', 'United Kingdom', '07923999000', '2020-11-22', '2', '2020-11-22', '2');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (3, 'Billing', 'HARPENDEN', 'NULL', 'Aldwich', NULL, 'AL5 2AY', 'United Kingdom', '07923333121', '2020-12-22', '3', '2020-12-22', '3');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (4, 'Customer', 'MYLOR BRIDGE', 'NULL', 'Transmere', NULL, 'TR11 1HP', 'United Kingdom', '07929657121', '2020-12-22', '4', '2020-12-22', '4');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (5, 'Customer', 'TURBRIDGE', 'TURBRIDGE', 'Southampton', 'Bedfordshire', 'SA34 1YQ', 'United Kingdom', '07924444121', '2020-12-22', '5', '2020-12-22', '5');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (6, 'Billing', 'GILSLAND', 'GILSLAND', 'Cardiff', 'Cornwall', 'CA6 4SN', 'United Kingdom', '07926677121', '2020-12-22', '6', '2020-12-22', '6');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (7, 'Customer', 'Snowshill', 'Snowshill', 'Gloucestershire', 'Northumberland', 'GL7 4SN', 'United Kingdom', '07927777121', '2020-12-22', '7', '2020-12-22', '7');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (8, 'Customer', 'TURBRIDGE', 'TURBRIDGE', 'Southampton', 'Bedfordshire', 'SA34 1YQ', 'United Kingdom', '07924444121', '2020-12-22', '8', '2020-12-22', '8');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (9, 'Customer', 'Snowshill', 'Snowshill', 'Gloucestershire', 'Northumberland', 'GL9 4SN', 'United Kingdom', '09929999121', '2020-12-22', '9', '2020-12-22', '9');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (10, 'Billing', 'GILSLAND', 'GILSLAND', 'Cardiff', 'Cornwall', 'CA6 4SN', 'United Kingdom', '07926677121', '2020-12-22', '10', '2020-12-22', '10');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (11, 'Customer', 'Ombersley', 'Ombersley', 'Worcestershire', 'Norfolk', 'WO7 4NE', 'United Kingdom', '07926677121', '2020-12-22', '11', '2020-12-22', '11');

insert into address
  (address_id, address_type, address_line_1, address_line_2, city, county, postcode, country, telephone, date_created, created_by, date_modified, modified_by)
values
  (12, 'Customer', 'Snowshill', 'Snowshill', 'Gloucestershire', 'Northumberland', 'GL7 4SN', 'United Kingdom', '07926677121', '2020-12-22', '12', '2020-12-22', '12');




insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (1, 1, 1, 1, 1, '1', 'Individual', 'Active', 'EHR Data', 'KYC' , '2020-11-23', true, 'Employee1', 'Employee1', '2020-11-23', '1', '2020-11-23', '1');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (2, 2, 2, 2, 2, '2', 'Enterprise Customer', 'Active', 'Equaleyes', 'AML' , '2020-11-22', true, 'Employee2', 'Employee2', '2020-11-22', '2', '2020-11-22', '2');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (3, 3, 3, 3, 3, '3', 'Group Owner', 'Suspended', 'BSV Node', 'AML' , '2020-12-22', true, 'Employee3', 'Employee3', '2020-12-22', '3', '2020-12-22', '3');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (4, 4, 4, 4, 4, '4', 'Holding Company', 'New', 'SPV Channels', 'KYC' , '2020-12-22', false, 'Employee4', 'Employee4', '2020-12-22', '4', '2020-12-22', '4');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (5, 5, 5, 5, 3, '5', 'Other', 'New', 'Crea', 'KYC' , '2020-12-22', false, 'Employee5', 'Employee5', '2020-12-22', '5', '2020-12-22', '5');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (6, 6, 6, 6, 2, '6', 'Enterprise Customer', 'Active', 'Kompany', 'AML' , '2020-12-22', true, 'Employee6', 'Employee6', '2020-12-22', '6', '2020-12-22', '6');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (7, 7, 7, 7, 2, '7', 'Other', 'Active', 'BitBoss', 'AML' , '2020-12-22', true, 'Employee7', 'Employee7', '2020-12-22', '7', '2020-12-22', '7');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (8, 8, 8, 8, 1, '8', 'Partner (VAR)', 'Active', 'Bayesian Group', 'KYC' , '2020-12-22', true, 'Employee8', 'Employee8', '2020-12-22', '8', '2020-12-22', '8');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (9, 9, 9, 9, 1, '9', 'Partner (VAR)', 'Active', 'Tuvalu', 'KYC' , '2020-12-22', true, 'Employee9', 'Employee9', '2020-12-22', '9', '2020-12-22', '9');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (10, 10, 10, 10, 8, '10', 'Enterprise Customer', 'Active', 'Domineum', 'KYC' , '2020-12-22', true, 'Employee10', 'Employee10', '2020-12-22', '10', '2020-12-22', '10');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (11, 11, 11, 11, 8, '11', 'Partner (VAR)', 'Active', 'IBM', 'KYC' , '2020-12-22', true, 'Employee11', 'Employee11', '2020-12-22', '11', '2020-12-22', '11');

insert into customer_account
  (account_id, parent_account_id, owner_account_id, introduced_by_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, date_verified, quota_exceeded, account_manager, service_delivery_mgr, date_created, created_by, date_modified, modified_by
  )
values
  (12, 12, 12, 12, 10, '12', 'Enterprise Customer', 'Suspended', 'Ernest Young', 'KYC' , '2020-12-22', true, 'Employee12', 'Employee12', '2020-12-22', '12', '2020-12-22', '12');



insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (1, 1, '2020-11-23', '2020-11-23' , '2021-11-23', 'Pending', NULL, NULL, 6.69326, '2020-11-23', '1', '2020-11-23', '1');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (2, 2, '2020-11-22', '2020-11-22' , '2021-11-22', 'Pending', NULL, NULL, 6.00026, '2020-11-22', '2', '2020-11-22', '2');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (3, 3, '2020-12-22', '2020-12-22' , '2021-12-22', 'Suspended', NULL, NULL, 3.026, '2020-12-22', '3', '2020-12-22', '3');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (4, 4, '2020-12-22', '2020-12-22' , '2021-12-22', 'Suspended', NULL, NULL, 9.213, '2020-12-22', '4', '2020-12-22', '4');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (5, 5, '2020-12-22', '2020-12-22' , '2021-12-22', 'Pending', 'Signed', 'No variations', 9.213, '2020-12-22', '5', '2020-12-22', '5');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (6, 6, '2020-12-22', '2020-12-22' , '2021-12-22', 'Deactivated', 'Signed', 'No variations', 9.213, '2020-12-22', '6', '2020-12-22', '6');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (7, 7, '2020-12-22', '2020-12-22' , '2021-12-22', 'Pending', 'Signed', 'No variations', 9.213, '2020-12-22', '7', '2020-12-22', '7');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (8, 8, '2020-12-22', '2020-12-22' , '2021-12-22', 'Pending', 'Signed', 'No variations', 9.213, '2020-12-22', '8', '2020-12-22', '8');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (9, 9, '2020-12-22', '2020-12-22' , '2021-12-22', 'Deactivated', 'Not-Signed', 'No variations', 9.213, '2020-12-22', '9', '2020-12-22', '9');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (10, 10, '2020-12-22', '2020-12-22' , '2021-12-22', 'Suspended', 'Signed', 'No variations', 10.213, '2020-12-22', '10', '2020-12-22', '10');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (11, 11, '2020-12-22', '2020-12-22' , '2021-12-22', 'Deactivated', 'Signed', 'No variations', 11.213, '2020-12-22', '11', '2020-12-22', '11');

insert into contract
  (contract_id, account_id, activate_by_date, signed_date, expiry_date, contract_status, signed_contract, contract_variations, contract_spend_level, date_created, created_by, date_modified, modified_by)
values
  (12, 12, '2020-12-22', '2020-12-22' , '2021-12-22', 'Pending', 'Signed', 'No variations', 12.213, '2020-12-22', '12', '2020-12-22', '12');




insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, date_created, created_by, date_modified, modified_by)
values
  (1, 1, 1, 1, 'USD', '4', '2020-11-23', 'deactivate reason', '2020-11-23', '1', '2020-11-23', '1');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (2, 2, 2, 2, 'GBP', '2', '2020-11-22', 'deactivate reason', 1000, '2020-11-22', '2', '2020-11-22', '2');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (3, 3, 3, 3, 'USD', '6', '2020-12-22', 'deactivate reason', 20000, '2020-12-22', '3', '2020-12-22', '3');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (4, 4, 4, 4, 'GBP', '7', '2020-12-22', 'deactivate reason', 5000, '2020-12-22', '4', '2020-12-22', '4');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (5, 5, 5, 5, 'GBP', '9', '2020-12-22', 'deactivate reason', 15556, '2020-12-22', '5', '2020-12-22', '5');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (6, 6, 6, 6, 'GBP', '4', '2020-12-22', 'deactivate reason', 45000, '2020-12-22', '6', '2020-12-22', '6');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (7, 7, 7, 7, 'GBP', '2', '2020-12-22', 'deactivate reason', 55900, '2020-12-22', '7', '2020-12-22', '7');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (8, 8, 8, 8, 'GBP', '2', '2020-12-22', 'deactivate reason', 55900, '2020-12-22', '8', '2020-12-22', '8');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (9, 9, 9, 9, 'GBP', '2', '2020-12-22', 'deactivate reason', 11900, '2020-12-22', '9', '2020-12-22', '9');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (10, 10, 10, 10, 'GBP', '6', '2020-12-22', 'deactivate reason', 111000, '2020-12-22', '10', '2020-12-22', '10');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (11, 11, 11, 11, 'GBP', '7', '2020-12-22', 'deactivate reason', 31100, '2020-12-22', '11', '2020-12-22', '11');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_address_id, bill_currency, bill_vat_number, date_deactivated, reason_deactivated, outstanding_balance, date_created, created_by, date_modified, modified_by)
values
  (12, 12, 12, 12, 'GBP', '2', '2020-12-22', 'deactivate reason', 93200, '2020-12-22', '12', '2020-12-22', '12');




insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (1, 1, 1, 1, '2020-11-23', 'Pending', '2020-11-23', '2020-11-23', '1', '2020-11-23', '1');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (2, 2, 2, 2, '2020-11-22', 'Checked', '2020-11-22', '2020-11-22', '2', '2020-11-22', '2');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (3, 3, 3, 3, '2020-12-22', 'Provisioned', '2020-12-22', '2020-12-22', '3', '2020-12-22', '3');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (4, 4, 4, 4, '2020-12-22', 'New', '2020-12-22', '2020-12-22', '4', '2020-12-22', '4');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (5, 5, 5, 5, '2020-12-22', 'Checked', '2020-12-22', '2020-12-22', '5', '2020-12-22', '5');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (6, 6, 6, 6, '2020-12-22', 'Checked', '2020-12-22', '2020-12-22', '6', '2020-12-22', '6');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (7, 7, 7, 7, '2020-12-22', 'Checked', '2020-12-22', '2020-12-22', '7', '2020-12-22', '7');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (8, 8, 8, 8, '2020-12-22', 'Checked', '2020-12-22', '2020-12-22', '8', '2020-12-22', '8');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (9, 9, 9, 9, '2020-12-22', 'New', '2020-12-22', '2020-12-22', '9', '2020-12-22', '9');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (10, 10, 10, 10, '2020-12-22', 'New', '2020-12-22', '2020-12-22', '10', '2020-12-22', '10');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (11, 11, 11, 11, '2020-12-22', 'Checked', '2020-12-22', '2020-12-22', '11', '2020-12-22', '11');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, date_created, created_by, date_modified, modified_by)
values
  (12, 12, 12, 12, '2020-12-22', 'Checked', '2020-12-22', '2020-12-22', '12', '2020-12-22', '12');




insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (1, 1, 1, 1, 'Available', '2020-11-23', '2020-11-23', '2020-11-23', '1', '2020-11-23', '1');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (2, 2, 2, 2, 'Suspended', '2020-11-22', '2020-11-22', '2020-11-22', '2', '2020-11-22', '2');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (3, 3, 3, 3, 'Ended', '2020-12-22', '2020-12-22', '2020-12-22', '3', '2020-12-22', '3');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (4, 4, 4, 4, 'Pending', '2020-12-22', '2020-12-22', '2020-12-22', '4', '2020-12-22', '4');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (5, 5, 5, 5, 'Available', '2020-12-22', '2020-12-22', '2020-12-22', '5', '2020-12-22', '5');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (6, 6, 6, 6, 'Ended', '2020-12-22', '2020-12-22', '2020-12-22', '6', '2020-12-22', '6');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (7, 7, 7, 7, 'Ended', '2020-12-22', '2020-12-22', '2020-12-22', '7', '2020-12-22', '7');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (8, 8, 8, 8, 'Available', '2020-12-22', '2020-12-22', '2020-12-22', '8', '2020-12-22', '8');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (9, 9, 9, 9, 'Available', '2020-12-22', '2020-12-22', '2020-12-22', '9', '2020-12-22', '9');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (10, 10, 10, 10, 'Ended', '2020-12-22', '2020-12-22', '2020-12-22', '10', '2020-12-22', '10');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (11, 11, 11, 11, 'Available', '2020-12-22', '2020-12-22', '2020-12-22', '11', '2020-12-22', '11');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, end_date, date_created, created_by, date_modified, modified_by)
values
  (12, 12, 12, 12, 'Available', '2020-12-22', '2020-12-22', '2020-12-22', '12', '2020-12-22', '12');




-- DO NOT INSERT THE BELOW KEYS, THEY WILL NOT WORK BECAUSE OF ENCRIPTION! YOU NEED TO CREATE THEM!
-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('55198248082f4f29537ad8d9b6ef2a3e266383580728b152da4e87981f54e2d2', 1, 1, 1, true, '2020-11-23', '1', '2020-11-23', '1');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('44198248082f4f29000hj8d9b6ef2a3e266383580728b152da4e87981f54e2d2', 2, 2, 2, false, '2020-11-22', '2', '2020-11-22', '2');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('4ec866b6f3f9df30b72888bb2745a7ed93cd99fed910cbbc9d7c6f05bedcd283', 3, 3, 3, true, '2020-12-22', '3', '2020-12-22', '3');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('03120b593aa074da321b2e9bbfa45606e39f6ded13068743aab5c087ffb10a6a', 4, 4, 4, true, '2020-12-22', '4', '2020-12-22', '4');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('680d509faebbdf419553752c3ed951780102bd74677f3a8e55b0f5e7514d19b6', 5, 5, 5, false, '2020-12-22', '5', '2020-12-22', '5');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('71cf14e4e008282822017112a93cf21a9dacfadc11d13f775c0e04599c1cc099', 6, 6, 6, false, '2020-12-22', '6', '2020-12-22', '6');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('71cf14e4e008282822017112a93cf21a9dacfadc11d13f775c0e04599c1cc077', 7, 7, 7, false, '2020-12-22', '7', '2020-12-22', '7');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('71cf14e4e008282822018782a93cf21a9dacfadc11d13f775c0e04599c1cc077', 8, 8, 8, false, '2020-12-22', '8', '2020-12-22', '8');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('33cf14e4e008282822018782a93cf21a9dacfadc11d13f775c0e04599c1cc066', 9, 9, 9, false, '2020-12-22', '9', '2020-12-22', '9');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('67gh14e4e008282822018782a93cf21a9dacfadc11d13f775c0e04599c1cd000', 10, 10, 10, false, '2020-12-22', '10', '2020-12-22', '10');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('67gh14e4e008232822018782a93cf21a9dacfadc11d13f775c0e04599c1cd111', 11, 11, 11, false, '2020-12-22', '11', '2020-12-22', '11');

-- insert into api_key
--   (api_key, account_id, contact_ps_user_id, subscription_id, key_active, date_created, created_by, date_modified, modified_by)
-- values
--   ('12hh54e4e008282822018782a93cf21a9dacfadc11d13f775c0e04599c1hh768', 12, 12, 12, true, '2020-12-22', '12', '2020-12-22', '12');




insert into service_group
  (group_name, group_description, group_endpoint, date_created, created_by, date_modified, modified_by)
values
  ('EventStream', 'EventStream', 'http://data.nchain.com/api/v1/EventStream', '2020-11-23', '1', '2020-11-23', '1');

insert into service_group
  (group_name, group_description, group_endpoint, date_created, created_by, date_modified, modified_by)
values
  ('EventData', 'EventData', 'http://data.nchain.com/api/v1/EventData', '2020-11-23', '2', '2020-11-23', '2');

insert into service_group
  (group_name, group_description, group_endpoint, date_created, created_by, date_modified, modified_by)
values
  ('SmartContracts', 'SmartContracts', 'http://data.nchain.com/api/v1/SmartContracts', '2020-11-23', '3', '2020-11-23', '3');




insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('ES-create', 'ES-create', 'Available', 'EventStream', '2020-11-23', '1', '2020-11-23', '1');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('ES-appendData', 'ES-appendData', 'Available', 'EventStream', '2020-11-22', '2', '2020-11-22', '2');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('ES-destroy', 'ES-destroy', 'Archived', 'EventStream', '2020-12-22', '3', '2020-12-22', '3');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('SC-new', 'SC-new', 'Pending', 'EventStream', '2020-12-22', '4', '2020-12-22', '4');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('ES-settlement', 'ES-settlement', 'Archived', 'EventStream', '2020-12-22', '5', '2020-12-22', '5');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('SC-send', 'SC-send', 'Pending', 'EventStream', '2020-12-22', '6', '2020-12-22', '6');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('SC-history', 'SC-history', 'Pending', 'EventStream', '2020-12-22', '7', '2020-12-22', '7');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('SC-indexes', 'SC-indexes', 'Available', 'EventStream', '2020-12-22', '8', '2020-12-22', '8');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('SC-rendezvous', 'SC-rendezvous', 'Available', 'EventStream', '2020-12-22', '9', '2020-12-22', '9');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('ES-rendezvous', 'ES-rendezvous', 'Available', 'EventStream', '2020-12-22', '10', '2020-12-22', '10');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('ES-queryData', 'ES-queryData', 'Available', 'EventStream', '2020-12-22', '11', '2020-12-22', '11');

insert into service
  (service_name, service_description, status, service_group_name, date_created, created_by, date_modified, modified_by)
values
  ('SC-call', 'SC-call', 'Available', 'EventStream', '2020-12-22', '12', '2020-12-22', '12');




insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('ES-create', 'GB', 'Unit', true, 'api', '2020-12-23', '1', '2020-12-23', '1');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('ES-appendData', 'KB', 'Volume', false, 'qty', '2020-12-22', '2', '2020-12-22', '2');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('ES-destroy', 'MB', 'Tiered', true, 'duration', '2020-12-22', '3', '2020-12-22', '3');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('SC-new', 'Request', 'Stairstep', true, 'api', '2020-12-22', '4', '2020-12-22', '4');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('ES-settlement', 'Second', 'Hybrid', true, 'executionTimeMs', '2020-12-22', '5', '2020-12-22', '5');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('SC-send', 'Minute', 'Hybrid', true, 'responseBytes', '2020-12-22', '6', '2020-12-22', '6');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('SC-history', 'Hour', 'Stairstep', true, 'stateSavedBytes', '2020-12-22', '7', '2020-12-22', '7');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('SC-indexes', 'Day', 'Tiered', true, 'pseudoRandomBytes', '2020-12-22', '8', '2020-12-22', '8');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('SC-rendezvous', 'Month', 'Tiered', true, 'randomBytes', '2020-12-22', '9', '2020-12-22', '9');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('ES-rendezvous', 'Year', 'Volume', true, 'randomBytes', '2020-12-22', '10', '2020-12-22', '10');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('ES-queryData', 'Hour', 'Volume', true, 'pseudoRandomBytes', '2020-12-22', '11', '2020-12-22', '11');

insert into service_details
  (service_name, unit_of_measure, pricing_model, inactive, modifier, date_created, created_by, date_modified, modified_by)
values
  ('SC-call', 'MB', 'Stairstep', true, 'stateSavedBytes', '2020-12-22', '12', '2020-12-22', '12');




insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (1, 1, 1, 1, 'GB', 'Stairstep', 'modifier1', 5.555, 4.444, 9 , 99, 8.8888, '2020-11-23', '2020-11-23', '2020-11-23', '1', '2020-11-23', '1');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (2, 2, 2, 2, 'KB', 'Volume', 'modifier2', 3.523, 2.234, 11 , 111, 3.8348, '2020-11-22', '2020-11-22', '2020-11-22', '2', '2020-11-22', '2');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (3, 3, 3, 3, 'MB', 'Tiered', 'modifier3', 2.199, 7.009, 22 , 222, 8.1234, '2020-12-22', '2020-12-22', '2020-12-22', '3', '2020-12-22', '3');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (4, 4, 4, 4, 'Request', 'Hybrid', 'modifier4', 7.1229, 4.229, 8 , 67, 9.1444, '2020-12-22', '2020-12-22', '2020-12-22', '4', '2020-12-22', '4');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (5, 5, 5, 5, 'Second', 'Tiered', 'modifier5', 7.1229, 5.229, 8 , 67, 9.1555, '2020-12-22', '2020-12-22', '2020-12-22', '5', '2020-12-22', '5');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (6, 6, 6, 6, 'Minute', 'Tiered', 'modifier6', 7.1229, 6.229, 8 , 67, 9.1648, '2020-12-22', '2020-12-22', '2020-12-22', '6', '2020-12-22', '6');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (7, 7, 7, 7, 'Hour', 'Stairstep', 'modifier7', 7.1229, 7.229, 8 , 77, 9.1748, '2020-12-22', '2020-12-22', '2020-12-22', '7', '2020-12-22', '7');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (8, 8, 8, 8, 'Request', 'Stairstep', 'modifier8', 8.1229, 8.229, 8 , 88, 9.1848, '2020-12-22', '2020-12-22', '2020-12-22', '8', '2020-12-22', '8');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (9, 9, 9, 9, 'Request', 'Stairstep', 'modifier9', 9.1229, 9.229, 9 , 99, 9.1949, '2020-12-22', '2020-12-22', '2020-12-22', '9', '2020-12-22', '9');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (10, 10, 10, 10, 'Request', 'Tiered', 'modifier10', 10.12210, 10.2210, 10 , 1010, 10.110410, '2020-12-22', '2020-12-22', '2020-12-22', '10', '2020-12-22', '10');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (11, 11, 11, 11, 'Hour', 'Hybrid', 'modifier11', 11.12211, 11.2211, 11 , 1111, 11.111411, '2020-12-22', '2020-12-22', '2020-12-22', '11', '2020-12-22', '11');

insert into service_rate_card
  (rate_card_id, product_offer_id, subscription_id, service_id, unit_of_measure, pricing_model, modifier, price_per_unit, currency_rate, start_range, end_range, bsv_tx_fee, activate_by_date, expiry_date, date_created, created_by, date_modified, modified_by)
values
  (12, 12, 12, 12, 'MB', 'Hybrid', 'modifier12', 12.12212, 12.2212, 12 , 1212, 12.121412, '2020-12-22', '2020-12-22', '2020-12-22', '12', '2020-12-22', '12');




insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (1, 1, 'ES-create');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (2, 2, 'ES-appendData');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (3, 3, 'ES-destroy');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (4, 4, 'SC-new');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (6, 6, 'SC-send');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (7, 7, 'SC-history');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (8, 8, 'SC-indexes');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (9, 9, 'SC-rendezvous');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (10, 10, 'ES-rendezvous');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (11, 11, 'ES-queryData');

insert into subscription_service
  (subscription_id, service_id, service_name)
values
  (12, 12, 'SC-call');




insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (1, 1, 1, 'John', 'Doe', 1, '07940675464', 'john@doe.com', '1', 'Business', '2020-11-23', '1', '2020-11-23', '1');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (2, 2, 2, 'Bennie', 'Harris', 2, '07941234464', 'bennie@harris.com', '2', 'Legal', '2020-11-22', '2', '2020-11-22', '2');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (3, 3, 3, 'Augusta', 'Knowles', 3, '07946696555', 'augusta@knowles.com', '3', 'Technical', '2020-12-22', '3', '2020-12-22', '3');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (4, 4, 4, 'Vickie', 'Rohrer', 3, '07944444555', 'vickie@rohrer.com', '4', 'Technical', '2020-12-22', '4', '2020-12-22', '4');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (5, 5, 5, 'Clarence', 'Stanhope', 3, '07955555555', 'clarence@stanhope.com', '5', 'Legal', '2020-12-22', '5', '2020-12-22', '5');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (6, 6, 6, 'Robert', 'Bernard', 3, '07966732866', 'robert@bernard.com', '6', 'Technical', '2020-12-22', '6', '2020-12-22', '6');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (7, 7, 7, 'Vickie', 'Rohrer', 3, '07977777555', 'vickie@rohrer.com', '7', 'Technical', '2020-12-22', '7', '2020-12-22', '7');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (8, 8, 8, 'Clarence', 'Stanhope', 3, '07955555555', 'clarence@stanhope.com', '8', 'Technical', '2020-12-22', '8', '2020-12-22', '8');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (9, 9, 9, 'Clarence', 'Stanhope', 3, '07955555555', 'clarence@stanhope.com', '9', 'Legal', '2020-12-22', '9', '2020-12-22', '9');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (10, 10, 10, 'John', 'Roach', 3, '07955563486', 'john@roach.com', '10', 'Technical', '2020-12-22', '10', '2020-12-22', '10');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (11, 11, 11, 'Robert', 'Bernard', 3, '07944732844', 'robert@bernard.com', '11', 'Technical', '2020-12-22', '11', '2020-12-22', '11');

insert into contact
  (contact_id, reports_to_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_mobile_no, contact_email_address, contact_ps_user_id, contact_type, date_created, created_by, date_modified, modified_by)
values
  (12, 12, 12, 'Clarence', 'Stanhope', 3, '07955555555', 'clarence@stanhope.com', '12', 'Technical', '2020-12-22', '12', '2020-12-22', '12');




insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (1, 'Client1', '2020-11-23', '2020-11-23', '1', '2020-11-23', '1');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (2, 'Client2', '2020-11-22', '2020-11-22', '2', '2020-11-22', '2');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (3, 'Client3', '2020-12-22', '2020-12-22', '3', '2020-12-22', '3');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (4, 'Client4', '2020-12-22', '2020-12-22', '4', '2020-12-22', '4');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (5, 'Client5', '2020-12-22', '2020-12-22', '5', '2020-12-22', '5');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (6, 'Client6', '2020-12-22', '2020-12-22', '6', '2020-12-22', '6');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (7, 'Client7', '2020-12-22', '2020-12-22', '7', '2020-12-22', '7');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (8, 'Client8', '2020-12-22', '2020-12-22', '8', '2020-12-22', '8');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (9, 'Client9', '2020-12-22', '2020-12-22', '9', '2020-12-22', '9');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (10, 'Client10', '2020-12-22', '2020-12-22', '10', '2020-12-22', '10');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (11, 'Client11', '2020-12-22', '2020-12-22', '11', '2020-12-22', '11');

insert into role
  (role_id, role_description, inactivate_date, date_created, created_by, date_modified, modified_by)
values
  (12, 'Client12', '2020-12-22', '2020-12-22', '12', '2020-12-22', '12');




insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('1', 'Plat Serv', '2020-11-23', '2020-11-23', '2020-11-23', '1', '2020-11-23', '1');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('2', 'Plat Serv', '2020-11-22', '2020-11-22', '2020-11-22', '2', '2020-11-22', '2');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('3', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '3', '2020-12-22', '3');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('4', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '4', '2020-12-22', '4');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('5', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '5', '2020-12-22', '5');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('6', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '6', '2020-12-22', '6');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('7', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '7', '2020-12-22', '7');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('8', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '8', '2020-12-22', '8');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('9', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '9', '2020-12-22', '9');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('10', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '10', '2020-12-22', '10');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('11', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '11', '2020-12-22', '11');

insert into terms_and_conditions
  (ps_terms_id, ps_terms_description, active_by_date, date_expired, date_created, created_by, date_modified, modified_by)
values
  ('12', 'Plat Serv', '2020-12-22', '2020-12-22', '2020-12-22', '12', '2020-12-22', '12');




insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (1, 1);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (2, 2);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (3, 3);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (4, 4);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (5, 5);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (6, 6);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (7, 7);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (8, 8);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (9, 9);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (10, 10);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (11, 11);

insert into purchase_order_product_offer
  (purchase_order_id, product_offer_id)
values
  (12, 12);




insert into product_offer_service
  (product_offer_id, service_id)
values
  (1, 1);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (2, 2);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (3, 3);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (4, 4);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (5, 5);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (6, 6);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (7, 7);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (8, 8);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (9, 9);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (10, 10);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (11, 11);

insert into product_offer_service
  (product_offer_id, service_id)
values
  (12, 12);
