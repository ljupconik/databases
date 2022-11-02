alter table billed_charges add errorId int null;
alter table billed_charges add constraint fl_billed_charges_error
foreign key (errorid) references validation_messeges(errorid);

alter table open_events add errorId int null;
alter table open_events add constraint fl_open_events_error
foreign key (errorId) references validation_messeges(errorId);

alter table validation_messeges rename to validation_messages;

insert into validation_messages 
(errorId, errorcode, errordescription, datecreated)
values
(11, 'calc1', 'ServiceId for subscriptionId and chargeUnit not found', now());

insert into validation_messages 
(errorId, errorcode, errordescription, datecreated)
values
(12, 'calc2', 'RateCard for subscriptionId, chargeUnit, modifier and unitofmeasure not found', now());

insert into validation_messages 
(errorId, errorcode, errordescription, datecreated)
values
(13, 'calc3', 'RateCard for subscriptionId, chargeUnit, modifier and unitofmeasure not active', now());

insert into validation_messages 
(errorId, errorcode, errordescription, datecreated)
values
(14, 'calc4', 'RateCard for subscriptionId, chargeUnit, modifier and unitofmeasure has expired', now());

insert into validation_messages 
(errorId, errorcode, errordescription, datecreated)
values
(15, 'calc5', 'A bill_payer account for the accountId not found', now());

insert into validation_messages 
(errorId, errorcode, errordescription, datecreated)
values
(16, 'agg1', 'The event is followed by the invalid successor', now());

alter table billing_archive add column archive_id bigint;

create sequence billing_archive_archive_id_seq;

update billing_archive 
  set archive_id = a.new_id
from (
   select accountid, chargeitem , nextval('billing_archive_archive_id_seq') as new_id
   from billing_archive
   order by archiveddate 
) a
where a.accountid = billing_archive.accountid 
and a.chargeitem = billing_archive.chargeitem;

alter table billing_archive alter column archive_id set default nextval('billing_archive_archive_id_seq');

alter sequence billing_archive_archive_id_seq owned by billing_archive.archive_id;

alter table billing_archive  drop constraint billing_archive_pkey;

alter table billing_archive add constraint billing_archive_pkey primary key (archive_id);

--------------------------------------------------------------------------------------------------------------

UPDATE db_version
SET current_version = '1.2',
    updated = now();