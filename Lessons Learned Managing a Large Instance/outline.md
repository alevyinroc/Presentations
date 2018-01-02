# Pushing the Limits: Lessons Learned from 8000 Databases
## Harsh Realities
* SSMS tree view? Open once, don't refresh
* Select Database drop-down - don't bother
* You will write a lot of cursors
* You will write a lot of dynamic SQL
* You'll need a utility database
  * Beware the junk drawer/kitchen sink
  * Clean up after yourself


## Naming
* You have to have a naming convention for your databases
* Just don't let it get out of hand
* Lookup tables?
* Use `Application Name` in your connection strings

## Index Maintenance, Backups & CheckDB
* May have to go parallel
* Switching between databases gets expensive
  * Eventually, volume just catches up with you
* Transaction log backup frequency

## Inefficiencies
* Optimize for Ad Hoc
* Forget plan cache stability
* Monitoring tools
  * Some will run detailed queries against each database. Things stack up

## Distribute the work
* Consider sharding
* Common utility databases
  * Move to another instance
  * Put into an AG & keep copies on all instances

## Staying in sync
* If your schemas don't match, you're gonna have a bad time
* Multi Script to distribute schema changes

## Trim the Fat
* Stay on top of unused databases and get rid of them