--DOCKER,dev,qa,nft,stag,demo,prod

BEGIN;

insert into service_group
  (group_name, group_description, group_endpoint, group_status, created_by)
values
  ('EventStream Notarise', 'EventStream Notarise service group.', 'eventStreamNotarise', 'Active', 'b47093d1-b068-4251-a9d0-e3902c851bd9');

insert into service
  (service_name, service_description, status, service_group_name, created_by)
values
  ('ESN-create', 'ES-create component service for EventStream Notarise.', 'Active', 'EventStream Notarise', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ESN-appendEvent', 'ES-appendEvent component service for EventStream Notarise.', 'Active', 'EventStream Notarise', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ESN-finalise', 'ES-finalise component service for EventStream Notarise.', 'Active', 'EventStream Notarise', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ESN-queryData', 'ES-queryData component service for EventStream Notarise.', 'Active', 'EventStream Notarise', 'b47093d1-b068-4251-a9d0-e3902c851bd9'),
  ('ESN-queryPayload', 'ES-queryPayload component service for EventStream Notarise.', 'Active', 'EventStream Notarise', 'b47093d1-b068-4251-a9d0-e3902c851bd9');

DO $$
BEGIN
  for sub_id in 2..3 loop
  insert into subscription_service
    (subscription_id, service_id, service_name)
  values
    (sub_id, 9, 'ESN-create'),
    (sub_id, 10, 'ESN-appendEvent'),
    (sub_id, 11, 'ESN-finalise'),
    (sub_id, 12, 'ESN-queryData'),
    (sub_id, 13, 'ESN-queryPayload');
end
loop;
end;
$$;

COMMIT;