
ALTER TABLE product_offer ADD UNIQUE (product_offer_title);

ALTER TABLE service_rate_card ALTER COLUMN subscription_id DROP NOT NULL;

ALTER TABLE service_rate_card ALTER COLUMN subscription_id SET DEFAULT NULL;

ALTER TABLE service_rate_card ALTER COLUMN activate_by_date SET DEFAULT now();

------------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.4',
        updated = now();