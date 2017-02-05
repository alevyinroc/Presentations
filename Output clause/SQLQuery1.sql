select s.statusname,c.cachestatus,c.cacheid,c.cachename,c.created,c.lastupdated
from caches c join statuses s on c.cachestatus = s.statusid
where
	c.cachename like '[$aeiou]%'
	and  year(c.created) = year(c.lastupdated) and year(lastupdated) <= 2014 and s.statusname = 'Disabled';

begin transaction
	
update c set c.cachestatus = 2 output deleted.cacheid
	from caches c join statuses s on c.cachestatus = s.statusid where c.cachename like '[$aeiou]%'
	and  year(c.created) = year(c.lastupdated) and year(lastupdated) <= 2014 and s.statusname = 'Disabled'	
rollback transaction
