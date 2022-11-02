
BEGIN;

insert into service_group
(group_name, group_description, group_endpoint, group_status, created_by)
values
    ('EventStream Notarise', 'EventStream Notarise service group.', 'eventStreamNotarise', 'Active', ''),
    ('EventStream', 'EventStream service group.', 'eventStream', 'Active', ''),
    ('Store and Retrieve', 'Store and Retrieve service group.', 'storeRetrieve', 'Internal', ''),
    ('Add-ons', 'Add-ons service group.', 'addOns', 'Internal', '')
    ON CONFLICT (group_name) DO NOTHING;

ALTER SEQUENCE address_address_id_seq RESTART WITH 1001;
ALTER SEQUENCE customer_account_account_id_seq RESTART WITH 1001;
ALTER SEQUENCE contract_contract_id_seq RESTART WITH 1001;
ALTER SEQUENCE billing_billing_id_seq RESTART WITH 1001;
ALTER SEQUENCE purchase_order_purchase_order_id_seq RESTART WITH 1001;
ALTER SEQUENCE contact_contact_id_seq RESTART WITH 1001;
ALTER SEQUENCE subscription_subscription_id_seq RESTART WITH 1001;


insert into address
  (address_id, address_type, address_line_1, address_line_2, city, postcode, country, created_by)
values
  (501, 'Contact', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (502, 'Customer', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (503, 'Billing', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (504, 'Contact', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (505, 'Customer', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (506, 'Billing', '30 Market Place', 'Fitzrovia', 'London', 'W1W 8AP', 'United Kingdom', 'b47093d1-b068-4251-a9d0-e3902c851bd9');

insert into customer_account
  (account_id, account_address_id, customer_id, account_type, account_status, account_name, verification_type, bill_payer, account_manager, service_delivery_mgr, chargebee_customer, created_by)
values
  (501, 502, 'NCHAIN_IA', 'Enterprise Customer', 'Active', 'nChain IA', 'N/A' , false ,  'Cass Clark', 'Cass Clark', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (502, 505, 'NCHAIN_VCF', 'Enterprise Customer', 'Active', 'nChain VCF', 'N/A' , false , 'Cass Clark', 'Cass Clark', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9');

insert into contract
  (contract_id, account_id, activate_by_date, contract_status, contract_spend_level, created_by)
values
  (501, 501, '2021-06-14', 'Active', 500000, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (502, 502, '2021-06-14', 'Active', 500000, 'b47093d1-b068-4251-a9d0-e3902c851bd9');

insert into billing
  (billing_id, account_id, bill_payer_id, billing_account_id, billing_address_id, bill_currency, bill_vat_number, created_by)
values
  (501, 501, 501, 501, 503, 'CHF', 'N/A', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (502, 502, 502, 502, 506, 'CHF', 'N/A', 'b47093d1-b068-4251-a9d0-e3902c851bd9');

insert into purchase_order
  (purchase_order_id, account_id, contract_id, billing_id, order_date, order_status, approved_date, created_by)
values
  (501, 501, 501, 501, '2021-06-14', 'Approved', '2021-06-14', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (502, 502, 502, 502, '2021-06-14', 'Approved', '2021-06-14', 'b47093d1-b068-4251-a9d0-e3902c851bd9');

insert into subscription
  (subscription_id, account_id, purchase_order_id, billing_id, status, start_date, created_by)
values
  (501, 501, 501, 501, 'Active', '2021-06-14', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (502, 502, 502, 502, 'Active', '2021-06-14', 'b47093d1-b068-4251-a9d0-e3902c851bd9');

insert into contact
  (contact_id, account_id, contact_first_name, contact_last_name, contact_address_id, contact_email_address, contact_type, primary_contact, created_by)
values
  (501, 501, 'Andy', 'Moody', 501, 'a.moody@nchain.com', 'Billing', true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (502, 501, 'Cass', 'Clark', 501, 'c.clark@nchain.com', 'Technical', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (503, 502, 'Andy', 'Moody', 504, 'a.moody@nchain.com', 'Billing', true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  (504, 502, 'Cass', 'Clark', 504, 'c.clark@nchain.com', 'Technical', false, 'b47093d1-b068-4251-a9d0-e3902c851bd9');


COMMIT;
------------------------------------------------------------------------------------------

UPDATE db_version
SET current_version = '2.5',
    updated = now();