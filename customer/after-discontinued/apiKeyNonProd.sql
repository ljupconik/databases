--DOCKER,dev,qa,nft,stag,demo

BEGIN;

insert into api_key
  (api_key, account_id, subscription_id, key_active, created_by)
values
  ('asd34fQWbzasdvFzHTmEtXEmYhasdPh7CXWiFrdj', 1, 1, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('7d614232779fa674a9c6a4f870e34d13f14bdb91b68f57dc0c54e740ce82f660', 2, 2, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('fd513e1491ae34b7546f12b714eb1ba138190650e4d1a28398fc66737ea8bb72', 3, 3, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('FLw18A662U4ZUlJPmcgNx7bBlRDBDiBr6qpVix3x', 2, 2,  true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('GB7da6fbsdhgfv6vsdhsdvvbsbfdjsdfbshfv', 3, 3, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('TTfgs4sdfgsd8A662U4ZUlJPmcgNx7bBlRDshfv', 3, 3, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9')
    ON CONFLICT (api_key) DO NOTHING;

COMMIT;