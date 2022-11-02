ALTER TABLE document_retention ADD COLUMN date_created TIMESTAMP
WITH TIME ZONE DEFAULT now
() NOT NULL;

ALTER TABLE document_retention ADD COLUMN created_by VARCHAR
(255) NOT NULL;

ALTER TABLE document_retention ADD COLUMN date_modified TIMESTAMP
WITH TIME ZONE;

ALTER TABLE document_retention ADD COLUMN modified_by VARCHAR
(255);

ALTER TABLE document_retention RENAME COLUMN rentention_period TO retention_period;

ALTER TABLE service_rate_card ALTER COLUMN currency_code
SET
DEFAULT 'CHF';

CREATE TYPE offers_statuses AS ENUM
('Active', 'Expired', 'Inactive', 'Pending', 'Discontinued');

ALTER TABLE product_offer ALTER COLUMN offer_status DROP DEFAULT;

ALTER TABLE product_offer ALTER COLUMN offer_status
SET DATA TYPE
offers_statuses USING offer_status::text::offers_statuses;

DROP TYPE offer_statuses;

CREATE TYPE offer_statuses AS ENUM
('Active', 'Expired', 'Inactive', 'Pending', 'Discontinued');

ALTER TABLE product_offer ALTER COLUMN offer_status
SET DATA TYPE
offer_statuses USING offer_status::text::offer_statuses;

ALTER TABLE product_offer ALTER COLUMN offer_status
SET
DEFAULT 'Pending';

DROP TYPE offers_statuses;

CREATE TYPE services_statuses AS ENUM
( 'Pending', 'Available', 'Active', 'Discontinued', 'Suspended');

ALTER TABLE service ALTER COLUMN status DROP DEFAULT;

UPDATE service SET status='Available' WHERE service_name='ES-settlement';

ALTER TABLE service_group ALTER COLUMN group_status DROP DEFAULT;

ALTER TABLE service ALTER COLUMN status
SET DATA TYPE
services_statuses USING status::text::services_statuses;

ALTER TABLE service_group ALTER COLUMN group_status
SET DATA TYPE
services_statuses USING group_status::text::services_statuses;

DROP TYPE service_statuses;

CREATE TYPE service_statuses AS ENUM
( 'Pending', 'Available', 'Active', 'Discontinued', 'Suspended');

ALTER TABLE service ALTER COLUMN status
SET DATA TYPE
service_statuses USING status::text::service_statuses;

ALTER TABLE service_group ALTER COLUMN group_status
SET DATA TYPE
service_statuses USING group_status::text::service_statuses;

ALTER TABLE service ALTER COLUMN status
SET
DEFAULT 'Pending';

ALTER TABLE service_group ALTER COLUMN group_status
SET
DEFAULT 'Pending';

DROP TYPE services_statuses;

CREATE TYPE rates_card_statuses AS ENUM
('Pending', 'Active', 'Discontinued', 'Suspended', 'Expired');

ALTER TABLE service_rate_card ALTER COLUMN rate_card_status DROP DEFAULT;

ALTER TABLE service_rate_card ALTER COLUMN rate_card_status
SET DATA TYPE
rates_card_statuses USING rate_card_status::text::rates_card_statuses;

DROP TYPE rate_card_statuses;

CREATE TYPE rate_card_statuses AS ENUM
('Pending', 'Active', 'Discontinued', 'Suspended', 'Expired');

ALTER TABLE service_rate_card ALTER COLUMN rate_card_status
SET DATA TYPE
rate_card_statuses USING rate_card_status::text::rate_card_statuses;

ALTER TABLE service_rate_card ALTER COLUMN rate_card_status
SET
DEFAULT 'Pending';

DROP TYPE rates_card_statuses;

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.7',
        updated = now();