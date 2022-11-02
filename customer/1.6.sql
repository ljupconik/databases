
CREATE TYPE document_types AS ENUM('Design', 'Financial', 'Legal', 'Patent', 'Personal', 'Other');

CREATE TYPE classification_types AS ENUM('Confidential', 'Informational', 'Private', 'Public', 'Sensitive', 'N/A');

CREATE TABLE document_retention
(
	account_id INTEGER REFERENCES customer_account(account_id) NOT NULL,
	document_type document_types NOT NULL,
	classification classification_types NOT NULL,
	rentention_period INTEGER NOT NULL DEFAULT 90,
	CONSTRAINT account_id_document_type_pkey PRIMARY KEY (account_id, document_type)
);

ALTER TABLE service_details ADD COLUMN linked_modifiers TEXT;

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.6',
        updated = now();