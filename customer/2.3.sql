ALTER TABLE user_credentials ALTER COLUMN ps_user_password DROP NOT NULL;

ALTER TABLE user_credentials ADD COLUMN token_valid_after TIMESTAMP
WITH TIME ZONE;

ALTER TABLE purchase_order ADD COLUMN notes VARCHAR
(255);

ALTER TABLE subscription ADD COLUMN notes VARCHAR
(255);

ALTER TABLE api_key ADD COLUMN notes VARCHAR
(255);

CREATE TYPE units_of_measurement AS ENUM
('Request', 'KB', 'MB', 'GB', 'Second', 'Minute', 'Hour', 'Day', 'Month', 'Year', 'Create', 'N/A');

ALTER TABLE service_details ALTER COLUMN unit_of_measure
SET DATA TYPE
units_of_measurement USING unit_of_measure::text::units_of_measurement;

ALTER TABLE service_rate_card ALTER COLUMN unit_of_measure
SET DATA TYPE
units_of_measurement USING unit_of_measure::text::units_of_measurement;

DROP TYPE units_of_measure;

CREATE TYPE units_of_measure AS ENUM
('Request', 'KB', 'MB', 'GB', 'Second', 'Minute', 'Hour', 'Day', 'Month', 'Year', 'Create', 'N/A');

ALTER TABLE service_details ALTER COLUMN unit_of_measure
SET DATA TYPE
units_of_measure USING unit_of_measure::text::units_of_measure;

ALTER TABLE service_rate_card ALTER COLUMN unit_of_measure
SET DATA TYPE
units_of_measure USING unit_of_measure::text::units_of_measure;

DROP TYPE units_of_measurement;


------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '2.3',
        updated = now();
