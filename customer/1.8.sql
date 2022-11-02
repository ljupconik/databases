ALTER TABLE billing ALTER COLUMN bill_vat_number DROP NOT NULL;

ALTER TABLE purchase_order ADD COLUMN approved_by VARCHAR
(255);

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.8',
        updated = now();