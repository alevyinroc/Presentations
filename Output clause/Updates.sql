set statistics io on;
set nocount on;
select lastused from seq where seqid = 'Customer';
update seq set lastused = lastused + 1 where seqid = 'Customer';
select lastused from seq where seqid = 'Customer';

update seq  set lastused = lastused + 1
output inserted.lastused as 'NewValue'
where seqid = 'Customer';

update seq  set lastused = lastused + 1
output deleted.lastused as 'OldValue',inserted.lastused as 'NewValue'
where seqid = 'Customer';