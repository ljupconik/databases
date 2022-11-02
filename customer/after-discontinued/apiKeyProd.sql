--DOCKER,dev,qa,nft,stag,demo,prod

BEGIN;

insert into api_key
  (api_key, account_id, subscription_id, key_active, created_by)
values
  ('6af970dc32f935b98d7b38f10d076109828fc8ca7d6cc0c81eeaa05ec88c071a', 1, 1, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('b0eb3d814865acc27fe78bb39b95eb04a7618e670ddd6e41b64c79afedc555d2', 2, 2, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('a766f3353863688ffa96051cf70b0da2afcce3602760b5926ed876f5596eed39', 3, 3, true, 'b47093d1-b068-4251-a9d0-e3902c851bd9');

COMMIT;