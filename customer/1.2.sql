
CREATE TYPE account_statuses AS ENUM
('Active','Deactivated','New','Pending','Suspended','Verified');
CREATE TYPE account_types AS ENUM
('Enterprise Customer','Group Owner','Holding Company','Individual','Partner (VAR)', 'Other');
CREATE TYPE contract_statuses AS ENUM
('Active', 'Deactivated', 'New', 'Pending', 'Signed', 'Suspended');
CREATE TYPE purchase_order_statuses AS ENUM
('Approved', 'Checked', 'New', 'Pending', 'Provisioned');
CREATE TYPE subscriptions_statuses AS ENUM
('Active', 'Ended', 'Pending', 'Suspended', 'Trial');
CREATE TYPE service_statuses AS ENUM
('Active', 'Archived', 'Available', 'Ended', 'Pending', 'Suspended');
CREATE TYPE contact_types as ENUM
('Billing', 'Business', 'Legal', 'Technical', 'Other');
CREATE TYPE address_types as ENUM
('Billing', 'Contact', 'Customer' );
CREATE TYPE units_of_measure as ENUM
('Request', 'KB', 'MB', 'GB', 'Second', 'Minute', 'Hour', 'Day', 'Month', 'Year', 'N/A');
CREATE TYPE pricing_models as ENUM
('Flat fee', 'Hybrid', 'Stairstep', 'Tiered', 'Unit', 'Volume');
CREATE TYPE modifiers as ENUM
('api', 'qty', 'duration', 'executionTimeMs', 'pseudoRandomBytes', 'randomBytes', 'responseBytes', 'stateSavedBytes', 'N/A');
CREATE TYPE offer_types as ENUM
('Service', 'Application', 'Solution');
CREATE TYPE verification_types as ENUM
('AML', 'KYB', 'KYC', 'Credit Check', 'None', 'Other', 'N/A');
CREATE TYPE inactive_reasosns as ENUM
('Discontinued', 'Error', 'Other', 'Not ready');
CREATE TYPE offer_statuses as ENUM
('Active', 'Expired', 'Inactive', 'Pending');


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
	offer_status offer_statuses NOT NULL DEFAULT 'Pending',
	discount_percentage REAL NOT NULL DEFAULT 0,
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
	billing_account_id INTEGER NOT NULL,
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
	discount_percentage REAL NOT NULL DEFAULT 0,
	invoice_notes VARCHAR(255),
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
	contact_phone_no VARCHAR(30),
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

--------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.2',
        updated = now();