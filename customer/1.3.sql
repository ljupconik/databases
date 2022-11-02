
CREATE TYPE verifications_types AS ENUM('AML', 'Companies House', 'Credit Check', 'D&B', 'KYB', 'KYC', 'Who Is', 'None', 'Other', 'N/A');

ALTER TABLE customer_account ALTER COLUMN verification_type SET DATA TYPE verifications_types USING verification_type::text::verifications_types;

DROP TYPE verification_types;

CREATE TYPE verification_types AS ENUM('AML', 'Companies House', 'Credit Check', 'D&B', 'KYB', 'KYC', 'Who Is', 'None', 'Other', 'N/A');

ALTER TABLE customer_account ALTER COLUMN verification_type SET DATA TYPE verification_types USING verification_type::text::verification_types;

DROP TYPE verifications_types;

ALTER TABLE product_offer ADD COLUMN IF NOT EXISTS customized_offer BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE service_details ALTER COLUMN inactive_date DROP NOT NULL;

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.3',
        updated = now();