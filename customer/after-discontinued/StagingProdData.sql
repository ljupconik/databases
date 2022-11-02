--DOCKER,dev,qa,nft,stag,demo,prod

BEGIN;

--   CREATE TYPE services_statuses AS ENUM
--   ( 'Pending', 'Available', 'Active', 'Discontinued', 'Suspended', 'Internal');

-- ALTER TABLE service ALTER COLUMN status DROP DEFAULT;

-- ALTER TABLE service_group ALTER COLUMN group_status DROP DEFAULT;

-- ALTER TABLE service ALTER COLUMN status
-- SET DATA TYPE
-- services_statuses USING status::text::services_statuses;

-- ALTER TABLE service_group ALTER COLUMN group_status
-- SET DATA TYPE
-- services_statuses USING group_status::text::services_statuses;

-- DROP TYPE service_statuses;

-- CREATE TYPE service_statuses AS ENUM
-- ( 'Pending', 'Available', 'Active', 'Discontinued', 'Suspended', 'Internal');

-- ALTER TABLE service ALTER COLUMN status
-- SET DATA TYPE
-- service_statuses USING status::text::service_statuses;

-- ALTER TABLE service_group ALTER COLUMN group_status
-- SET DATA TYPE
-- service_statuses USING group_status::text::service_statuses;

-- ALTER TABLE service ALTER COLUMN status
-- SET
-- DEFAULT 'Pending';

-- ALTER TABLE service_group ALTER COLUMN group_status
-- SET
-- DEFAULT 'Pending';

-- DROP TYPE services_statuses;


insert into address
  (address_type, address_line_1, address_line_2, city, postcode, country, created_by)
values
  ('Contact', 'Schwindgasse 7/12', null, 'Vienna', '1040', 'Austria', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('Customer', 'Schwindgasse 7/12', null, 'Vienna', '1040', 'Austria', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('Billing', 'Schwindgasse 7/12', null, 'Vienna', '1040', 'Austria', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('Contact', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('Customer', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('Billing', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into customer_account
  (account_address_id, customer_id, account_type, account_status, account_name, verification_type, account_manager, service_delivery_mgr, created_by)
values
  (2, 'KOMPANY01', 'Enterprise Customer', 'Active', '360kompany AG', 'N/A' , 'Cass Clark', 'Cass Clark', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (5, 'NCHAIN01', 'Enterprise Customer', 'Active', 'nChain Limited', 'N/A' , 'Cass Clark', 'Cass Clark', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (5, 'NCHAIN02', 'Enterprise Customer', 'Active', 'nChain Support', 'N/A' , 'Cass Clark', 'Cass Clark', 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into contract
  (account_id, activate_by_date, contract_status, contract_spend_level, created_by)
values
  (1, '2021-07-01', 'Active', 0, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (2, '2021-04-01', 'Active', 500000, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (3, '2021-04-01', 'Active', 500000, 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into billing
  (account_id, bill_payer_id, billing_account_id, billing_address_id, bill_currency, bill_vat_number, created_by)
values
  (1, 1, 1, 3, 'EUR', 'ATU67091005', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (2, 2, 2, 6, 'CHF', 'GB227452511', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (3, 3, 3, 6, 'CHF', 'GB227452511', 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into purchase_order
  (account_id, contract_id, billing_id, order_date, order_status, approved_date, created_by)
values
  (1, 1, 1, '2021-07-01', 'Approved', '2021-07-01', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (2, 2, 2, '2021-04-01', 'Approved', '2021-04-01', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (3, 3, 3, '2021-04-01', 'Approved', '2021-04-01', 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into subscription
  (account_id, purchase_order_id, billing_id, status, start_date, created_by)
values
  (1, 1, 1, 'Active', '2021-07-01', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (2, 2, 2, 'Active', '2021-04-01', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (3, 3, 3, 'Active', '2021-04-01', 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into contact
  (account_id, contact_first_name, contact_last_name, contact_address_id, contact_email_address, contact_type, primary_contact, created_by)
values
  (1, 'Russell', 'Perry', 1, 'rep@kompany.com', 'Business', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (1, 'Carina', 'Wolf', 1, 'carina.wolf@kompany.com', 'Legal', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (1, 'Karin', 'Fischer', 3, 'karin.fischer@kompany.com', 'Billing', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (2, 'Andy', 'Moody', 4, 'a.moody@nchain.com', 'Billing', true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (2, 'Cass', 'Clark', 4, 'c.clark@nchain.com', 'Technical', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (3, 'Andy', 'Moody', 4, 'a.moody@nchain.com', 'Billing', true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (3, 'Cass', 'Clark', 4, 'c.clark@nchain.com', 'Technical', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into document_retention
  (account_id, document_type, classification, retention_period, created_by)
values
  (1, 'Other', 'N/A', 90, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (2, 'Other', 'N/A', 90, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (3, 'Other', 'N/A', 90, 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into service_group
  (group_name, group_description, group_endpoint, group_status, created_by)
values
  ('EventStream', 'EventStream service group.', 'eventStream', 'Active', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('Store and Retrieve', 'Store and Retrieve service group.', 'storeRetrieve', 'Internal', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('Add-ons', 'Add-ons service group.', 'addOns', 'Internal', 'b47093d1-b068-4251-a9d0-e3902c851bd9');


insert into service
  (service_name, service_description, status, service_group_name, created_by)
values
  ('ES-create', 'ES-create component service.', 'Active', 'EventStream', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ES-appendEvent', 'ES-appendEvent component service.', 'Active', 'EventStream', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ES-finalise', 'ES-finalise component service.', 'Active', 'EventStream', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ES-queryData', 'ES-queryData component service.', 'Active', 'EventStream', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ES-settlement', 'ES-settlement component service.', 'Active', 'EventStream', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('SR-store', 'SR-store component service.', 'Active', 'Store and Retrieve', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('SR-dataStorage', 'SR-dataStorage component service.', 'Active', 'Store and Retrieve', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('AO-subscriptionFee', 'AO-subscriptionFee component service.', 'Active', 'Add-ons', 'b47093d1-b068-4251-a9d0-e3902c851bd9');

DO $$
BEGIN
  for sub_id in 1..3 loop
  insert into subscription_service
    (subscription_id, service_id, service_name)
  values
    (sub_id, 1, 'ES-create'),
    (sub_id, 2, 'ES-appendEvent'),
    (sub_id, 3, 'ES-finalise'),
    (sub_id, 4, 'ES-queryData'),
    (sub_id, 5, 'ES-settlement'),
    (sub_id, 6, 'SR-store'),
    (sub_id, 7, 'SR-dataStorage'),
    (sub_id, 8, 'AO-subscriptionFee');
end
loop;
end;
$$;

COMMIT;