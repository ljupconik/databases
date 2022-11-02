CREATE TYPE contact_statuses AS ENUM
('Pending', 'Active', 'Suspended', 'Deactivated', 'Deleted' );

ALTER TABLE contact ADD COLUMN contact_status contact_statuses NOT NULL DEFAULT 'Active';

CREATE TYPE user_statusees AS ENUM
('Pending', 'Active', 'Suspended', 'Deactivated', 'Deleted');

ALTER TABLE user_credentials ALTER COLUMN user_status DROP DEFAULT;

ALTER TABLE user_credentials ALTER COLUMN user_status
SET DATA TYPE
user_statusees USING user_status::text::user_statusees;

DROP TYPE user_statuses;

CREATE TYPE user_statuses AS ENUM
('Pending', 'Active', 'Suspended', 'Deactivated', 'Deleted');

ALTER TABLE user_credentials ALTER COLUMN user_status
SET DATA TYPE
user_statuses USING user_status::text::user_statuses;

ALTER TABLE user_credentials ALTER COLUMN user_status
SET
DEFAULT 'Pending';

DROP TYPE user_statusees;

CREATE TYPE sub_service_type AS ENUM
('not applicable', 'notarise');

ALTER TABLE service ADD COLUMN sub_service sub_service_type DEFAULT NULL;

ALTER TABLE subscription_service ADD COLUMN sub_service sub_service_type DEFAULT NULL;

ALTER TABLE product_offer ADD COLUMN sub_service sub_service_type DEFAULT NULL;

ALTER TABLE contact ALTER COLUMN contact_ps_user_id SET DATA TYPE VARCHAR(255);

ALTER TABLE user_credentials ALTER COLUMN contact_ps_user_id SET DATA TYPE VARCHAR(255);

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '2.4',
        updated = now();