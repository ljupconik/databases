
CREATE TYPE rate_card_statuses AS ENUM
('Pending', 'Active', 'Ended', 'Discontinued');

ALTER TABLE service_rate_card ADD COLUMN rate_card_status rate_card_statuses DEFAULT 'Pending' NOT NULL;

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.5',
        updated = now();