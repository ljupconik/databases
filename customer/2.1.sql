ALTER TABLE service_rate_card DROP CONSTRAINT service_rate_card_subscription_id_service_id_start_range_key;

ALTER TABLE service_rate_card DROP CONSTRAINT service_rate_card_product_offer_id_service_id_start_range_key;

ALTER TABLE service_rate_card ADD CONSTRAINT rate_card_product_offer_service_modifier_st_range_pricing_key UNIQUE(product_offer_id, service_id, modifier, start_range, pricing_model);

ALTER TABLE service_rate_card ADD CONSTRAINT rate_card_subscription_service_modifier_st_range_pricing_key UNIQUE(subscription_id, service_id, modifier, start_range, pricing_model);

ALTER TABLE api_key DROP COLUMN contact_ps_user_id;

ALTER TABLE customer_account ADD COLUMN chargebee_customer BOOLEAN NOT NULL DEFAULT true;

CREATE TYPE modifierss AS ENUM('api', 'qty', 'duration', 'executionTimeMs', 'pseudoRandomBytes', 'randomBytes', 'responseBytes', 'stateSavedBytes', 'storage', 'bsvTx', 'N/A');

ALTER TABLE service_details ALTER COLUMN modifier SET DATA TYPE modifierss USING modifier::text::modifierss;

DROP TYPE modifiers;

CREATE TYPE modifiers AS ENUM('api', 'qty', 'duration', 'executionTimeMs', 'pseudoRandomBytes', 'randomBytes', 'responseBytes', 'stateSavedBytes', 'storage', 'bsvTx', 'N/A');

ALTER TABLE service_details ALTER COLUMN modifier SET DATA TYPE modifiers USING modifier::text::modifiers;

DROP TYPE modifierss;

CREATE TYPE user_statuses AS ENUM('Pending', 'Active', 'Suspended', 'Deactivated');

CREATE TYPE authorization_level_types AS ENUM('Create', 'Read (View)', 'Update', 'Delete');

CREATE TYPE invite_statuses AS ENUM('Invited', 'Accepted', 'Registered' );

CREATE TABLE user_credentials
(
	ps_user_id VARCHAR(255) PRIMARY KEY,
	ps_user_password VARCHAR(255) NOT NULL,
	last_user_login TIMESTAMP WITH TIME ZONE NOT NULL,
	last_password_reset TIMESTAMP WITH TIME ZONE,
	prev_password_1 VARCHAR(255),
	prev_password_2 VARCHAR(255),
	prev_password_3 VARCHAR(255),
	prev_password_4 VARCHAR(255),
	prev_password_5 VARCHAR(255),
	user_status user_statuses NOT NULL DEFAULT 'Pending',
	invite_status invite_statuses,
	invitation_sent TIMESTAMP WITH TIME ZONE,
	password_reset_sent TIMESTAMP WITH TIME ZONE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);


CREATE TABLE user_permissions
(
	ps_user_id VARCHAR(255) NOT NULL,
	user_allowed_access_to VARCHAR(255) NOT NULL,
	authorization_level authorization_level_types NOT NULL,
	last_accessed TIMESTAMP WITH TIME ZONE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255),
  CONSTRAINT ps_user_id_user_allowed_access_to_pkey PRIMARY KEY (ps_user_id, user_allowed_access_to)
);

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '2.1',
        updated = now();