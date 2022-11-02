
ALTER TABLE product_offer ADD COLUMN parent_offer_id INTEGER;

-- The below data has been moved here from the StagingProdData.sql file

CREATE TYPE services_statuses AS ENUM
  ( 'Pending', 'Available', 'Active', 'Discontinued', 'Suspended', 'Internal');

ALTER TABLE service ALTER COLUMN status DROP DEFAULT;

ALTER TABLE service_group ALTER COLUMN group_status DROP DEFAULT;

ALTER TABLE service ALTER COLUMN status
SET DATA TYPE
services_statuses USING status::text::services_statuses;

ALTER TABLE service_group ALTER COLUMN group_status
SET DATA TYPE
services_statuses USING group_status::text::services_statuses;

DROP TYPE service_statuses;

CREATE TYPE service_statuses AS ENUM
( 'Pending', 'Available', 'Active', 'Discontinued', 'Suspended', 'Internal');

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

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.9',
        updated = now();