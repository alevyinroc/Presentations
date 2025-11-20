select * from auditor.AllCheckDBs
select * from auditor.SQLInstances
--drop table auditor.SQLInstances
select * from sys.tables order by create_date desc

--delete from auditor.SQLInstances where collectiondate = '2025-11-18';
delete from auditor.BackupRestoreTests where collectiondate = '2025-11-18';
delete from auditor.AllCheckDBs where collectiondate = '2025-11-18';
delete from auditor.LastGoodCheckDB where collectiondate = '2025-11-18';
delete from auditor.BackupJobHistory where collectiondate = '2025-11-18';
delete from auditor.MSDBBackupHistory where collectiondate = '2025-11-18';
delete from auditor.LastBackups where collectiondate = '2025-11-18';
delete from auditor.AllPermissions where collectiondate = '2025-11-18';
delete from auditor.DatabaseRoleMembers where collectiondate = '2025-11-18';
delete from auditor.DatabaseRoles where collectiondate = '2025-11-18';
delete from auditor.DatabaseUsers where collectiondate = '2025-11-18';
delete from auditor.ServerRoleMembers where collectiondate = '2025-11-18';
delete from auditor.ServerRoles where collectiondate = '2025-11-18';
delete from auditor.InstanceLogins where collectiondate = '2025-11-18';
delete from auditor.DatabaseEncryption where collectiondate = '2025-11-18';
delete from auditor.DatabaseInventory where collectiondate = '2025-11-18';
delete from auditor.MasterDBCertificates where collectiondate = '2025-11-18';
delete from auditor.PatchLevels where collectiondate = '2025-11-18';
delete from auditor.ErrorLogPaths where collectiondate = '2025-11-18';

SQLInstances
create index IX_CollectionDate on auditor.BackupRestoreTests (collectiondate);
create index IX_CollectionDate on auditor.AllCheckDBs (collectiondate);
create index IX_CollectionDate on auditor.LastGoodCheckDB (collectiondate);
create index IX_CollectionDate on auditor.BackupJobHistory (collectiondate);
create index IX_CollectionDate on auditor.MSDBBackupHistory (collectiondate);
create index IX_CollectionDate on auditor.LastBackups (collectiondate);
create index IX_CollectionDate on auditor.AllPermissions (collectiondate);
create index IX_CollectionDate on auditor.DatabaseRoleMembers (collectiondate);
create index IX_CollectionDate on auditor.DatabaseRoles (collectiondate);
create index IX_CollectionDate on auditor.DatabaseUsers (collectiondate);
create index IX_CollectionDate on auditor.ServerRoleMembers (collectiondate);
create index IX_CollectionDate on auditor.ServerRoles (collectiondate);
create index IX_CollectionDate on auditor.InstanceLogins (collectiondate);
create index IX_CollectionDate on auditor.DatabaseEncryption (collectiondate);
create index IX_CollectionDate on auditor.DatabaseInventory (collectiondate);
create index IX_CollectionDate on auditor.MasterDBCertificates (collectiondate);
create index IX_CollectionDate on auditor.PatchLevels (collectiondate);
create index IX_CollectionDate on auditor.ErrorLogPaths (collectiondate);

alter table SQLInstances alter column collectiondate datetime not null;
alter table auditor.BackupRestoreTests alter column collectiondate datetime not null;
alter table auditor.AllCheckDBs alter column collectiondate datetime not null;
alter table auditor.LastGoodCheckDB alter column collectiondate datetime not null;
alter table auditor.BackupJobHistory alter column collectiondate datetime not null;
alter table auditor.MSDBBackupHistory alter column collectiondate datetime not null;
alter table auditor.LastBackups alter column collectiondate datetime not null;
alter table auditor.AllPermissions alter column collectiondate datetime not null;
alter table auditor.DatabaseRoleMembers alter column collectiondate datetime not null;
alter table auditor.DatabaseRoles alter column collectiondate datetime not null;
alter table auditor.DatabaseUsers alter column collectiondate datetime not null;
alter table auditor.ServerRoleMembers alter column collectiondate datetime not null;
alter table auditor.ServerRoles alter column collectiondate datetime not null;
alter table auditor.InstanceLogins alter column collectiondate datetime not null;
alter table auditor.DatabaseEncryption alter column collectiondate datetime not null;
alter table auditor.DatabaseInventory alter column collectiondate datetime not null;
alter table auditor.MasterDBCertificates alter column collectiondate datetime not null;
alter table auditor.PatchLevels alter column collectiondate datetime not null;
alter table auditor.ErrorLogPaths alter column collectiondate datetime not null;