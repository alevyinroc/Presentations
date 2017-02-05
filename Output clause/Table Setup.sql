use demo;
drop table if exists stores;
create table Stores (
	StoreId char(3) primary key not null
	,City varchar(20) not null
	,State char(2) not null
);
drop table if exists seq;
create table Seq (
	SeqId char(10) primary key not null
	,LastUsed int not null default 0
)
drop table if exists Customers;
create table Customers (
	CustomerId varchar(10) primary key not null
	,[Name] varchar(50) not null
);
insert into Stores values('ERU','East Rutherford','NJ');
insert into Stores values('FOX','Foxborough','MA');
insert into Stores values('SEA','Seattle','WA');
insert into Stores values('OAK','Oakland','CA');
insert into Seq values('Customer',0);
insert into Seq values('Orders',0);

insert into customers(CustomerId,[Name]) values 
	('ERU10','Elisha M'),
	('FOX12','Thomas B'),
	('OAK16','Derrick C'),
	('SEA3','Russel W')
;

select * from Customers;