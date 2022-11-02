CREATE TYPE invites_statuses AS ENUM
('Pending', 'Invited', 'Accepted', 'Registered');

ALTER TABLE user_credentials ALTER COLUMN invite_status SET DATA TYPE invites_statuses USING invite_status::text::invites_statuses;

DROP TYPE invite_statuses;

CREATE TYPE invite_statuses AS ENUM
('Pending', 'Invited', 'Accepted', 'Registered');

ALTER TABLE user_credentials ALTER COLUMN invite_status SET DATA TYPE invite_statuses USING invite_status::text::invite_statuses;

ALTER TABLE user_credentials ALTER COLUMN invite_status SET DEFAULT 'Pending';

ALTER TABLE user_credentials ALTER COLUMN invite_status SET NOT NULL;

DROP TYPE invites_statuses;

ALTER TABLE service_rate_card DROP CONSTRAINT rate_card_product_offer_service_modifier_st_range_pricing_key;

ALTER TABLE service_rate_card DROP CONSTRAINT rate_card_subscription_service_modifier_st_range_pricing_key;

CREATE UNIQUE INDEX rate_card_product_offer_service_modifier_st_range_pricing_key on service_rate_card(product_offer_id, service_id, modifier, start_range, pricing_model);

CREATE UNIQUE INDEX rate_card_subscription_service_modifier_st_range_pricing_key on service_rate_card(subscription_id, service_id, modifier, start_range, pricing_model);

DROP TABLE user_permissions;

DROP TABLE user_credentials;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE user_credentials
(
	ps_user_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
	contact_ps_user_id VARCHAR(30) REFERENCES contact(contact_ps_user_id) NOT NULL,
	ps_user_password VARCHAR(255) NOT NULL,
	last_user_login TIMESTAMP WITH TIME ZONE,
	last_password_reset TIMESTAMP WITH TIME ZONE,
	prev_password_1 VARCHAR(255),
	prev_password_2 VARCHAR(255),
	prev_password_3 VARCHAR(255),
	prev_password_4 VARCHAR(255),
	prev_password_5 VARCHAR(255),
	user_status user_statuses NOT NULL DEFAULT 'Pending',
	invite_status invite_statuses NOT NULL DEFAULT 'Pending',
	invitation_sent TIMESTAMP WITH TIME ZONE,
	password_reset_sent TIMESTAMP WITH TIME ZONE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255)
);

CREATE TABLE user_permissions
(
	ps_user_id UUID REFERENCES user_credentials(ps_user_id) NOT NULL,
	user_allowed_access_to INTEGER NOT NULL,
	object_name VARCHAR(255),
	authorization_level INTEGER NOT NULL,
	last_accessed TIMESTAMP WITH TIME ZONE,
	date_created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	created_by VARCHAR(255) NOT NULL,
	date_modified TIMESTAMP WITH TIME ZONE,
	modified_by VARCHAR(255),
  CONSTRAINT ps_user_id_user_allowed_access_to_pkey PRIMARY KEY (ps_user_id, user_allowed_access_to)
);

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '2.2',
        updated = now();

