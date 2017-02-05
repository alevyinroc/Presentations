--insert into customers (customerid,[name]) inserted.customerid,inserted.[name] values ('MIN5','Teddy B');

insert into customers (customerid,[name])
output inserted.customerid,inserted.name
values ('MIN5','Teddy B');

delete from customers output deleted.customerid,deleted.[name] where Customerid = 'MIN5' ;