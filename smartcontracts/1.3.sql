ALTER TABLE contract_instances
  ADD instance_seqnr bigint;

UPDATE contract_instances
  SET instance_seqnr = 1
  WHERE instance_seqnr IS NULL; -- WHERE is just in case if command is run on already updated DB by mistake


ALTER TABLE contract_instances
  ALTER COLUMN instance_seqnr SET NOT NULL;


--------------------------------------------------------------------------------------

UPDATE db_version
    SET current_version = '1.3',
        updated = now();
