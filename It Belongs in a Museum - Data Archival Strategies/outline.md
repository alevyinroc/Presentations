#Intro
#Why Archive?
* We just don't need it
  * Do we really need data about customers we haven't seen in 15 years?
* Data aging/retention policy
* Security
  * PII
* Space
  * Including backups
  * Put lesser-used data on cheaper storage
* Performance
  * Including maintenace
  * Including backups
  * Let's say you manage 500 properties, and the property ID is an indexed field (because it probably should be). Your index histogram looks like this (show). If you sell off half the properties, you might get sub-optimal execution plans because of the row count estimates. If you can move those properties out, the index histogram looks like this (show) - and now your estimates will be better. 

#Where to put it?
* New tables, same database
* New database, same instance
* Separate instance
  * Not getting into that here
* Stretch Tables in Azure

#Pitfalls
* Fragmentation/empty space on pages
  * Depending upon your clustered index, may result in lots of empty space in pages
* Throw indexes & stats out of whack
  * Can be mitigated by performing maintenance
* Poor performance while running
  * Depends on how you do your moves
* Another database to manage

#How to do it?
##Insert, then Delete
This is usually what people think of first
###Same `WHERE` clause
* But you risk losing data that was written/changed while you were copying
  * Copy, wait, delete
* Lock escalation on the `DELETE`s

###`WHERE EXISTS`
* Don't risk losing data
* Do risk missing stuff you should be deleting
* Lock escalation on the `DELETE`s

##`DELETE` with `OUTPUT` clause
* Atomic
* Fewer page reads?
* Lock escalation on the `DELETE`s?

##Partition swap
* Enterprise only
* Requires more planning up front
  * Whole partitions only
  * Must be in the same filegroup
  * Can only move within the same database
* **Very** fast

##Stretch Tables in Azure

###SSIS to files
###BCP to files



#But I Still Need to Query it!
* Use a view
* UNION between the archive & online
* With Stretch Tables, it's seamless!

#Alternatives for Performance
* Filtered index
  * `WHERE RMPROPID IN (SELECT RMPROPD FROM RMPROP WHERE INACTIVE <> 'Y'`)
  * Create an `ARCHIVED` field & filtered index on that
    * Have to update your queries to exclude by this field
* Indexed view
  * UDFs need to use `SCHEMABINDING` too