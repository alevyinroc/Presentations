# What is dbatools?
* Open Source PowerShell module for DBAs
* Started by Chrissy who needed to migrate between instances
	* One big script that got broken down into its constituent parts
* Swiss Army Knife
* 340+ functions
* 100+ contributors
	* The project has arrived because we had a debate about tabs vs. spaces

#Microsoft Support for PowerShell
* `sqlps`
	* Released, then idle
	* Slow
	* Buggy
	* Only available with SSMS
* `sqlserver`
	* Released, then idle for a while
	* Still only available with SSMS
	* Fixed a lot of bugs
	* New functions
	* Faster
* `sqlserver` in the PowerShell Gallery
	* Microsoft heard the community and started putting resources into it

#dbaools vs. `sqlserver`

Drew has a terrific talk about using the SQL Server PowerShell module. I’ve seen it a couple times and Drew has a lot of great advice for getting started with that module. He’s even a contributor to DBA tools.

Why am I telling you this? Because you won’t always be able to use DBAtools. You might be:

* On a locked-down jump box
* In an environment that doesn’t allow Open Source software.
* In environment that doesn't allow any external third-party utilities to be added in.

So if those apply do you definitely check out Drews session because that’s going to give you more the background that SQL Server module

What I’m going to show you today how you can take what you’ve learned from about power shell and the SQL Server module up to the next level and that’s with dbatools

#What does it do?
## Instance migrations
## Stand up new instance
- Memory
- Maxdop
- Mail
- Other configuration 
- Copy users
- Traceflags
- Maintenance solution, first responder kit, sp_whoisactive
	- schedule ola jobs 
	- Update/install the above
##Routine tasks
- Restart instance.
	- If you give a server name all instances will be restarted at once
- Copy-dbatable
- Import data to a table
- Copy databases
- Copy jobs
- Review error log

# Contribute!
- Github
- Tutorials
- What to do?
	- Documentation
	- Functions
	- Bug fixes
- Just one line