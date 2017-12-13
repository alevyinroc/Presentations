I'm a DBA. Which means that my most important jobs are:
 * To not spend all of the company's money to make up for inefficiencies
 * To make sure data is delivered accurately and quickly
 * To protect the integrity of the company's data

You're developers, and I want us to be friends. But sometimes, you make it really difficult. Let's talk about that.

What can I do for you?
What can you do for me?

## Basics
* Connection Strings
* Parameterized Queries
* Stored Procedures

## Talk to me!

 * This is a collaboration
   * Don't wait for me to come looking for you when your query hammers the database
   * I don't want to blame the application code because "the system is slow"
   * I don't want you to blame the database because "the system is slow"
   * Instead, we'll both go after the network and SAN admins
 * Talk to me about how many databases you're going to need
   * Multi-tenant - one DB per tenant vs. all tenants in one DB
     * One DB Per Tenant
       * Convenient from a separation perspective
       * OK for a few tenants
       * But What about 100, 1000 or 5000?
       * Schema changes, indexes, stored procs, plan guides, etc. have to be pushed to all databases at once
       * Replication becomes a major headache
       * Overhead becomes magnified
          * Backups, CheckDB, Query Store
          * Plan cache churn
          * Checkout line example
   * One DB
     * Trickier security
     * "Client key" fields
     * Schema changes may still take a while
      * But only have to be done once
    * Can take better advantage of compression
  * Talk to me about the type of data you're working with
    * Good data type choices = more efficient
    * Store your dates as dates
    * Store phone numbers & ZIP codes as strings
    * Limit the size of text fields
    * If something is a number, store it as a number
     * Scientific notation may not translate to a valid number type (out of bounds)
 * Talk to me about the rules around your data
   * Foreign key constraints
     * Helps everyone understand the relationships between the tables
   * Field constraints
   * I don't trust your app to protect the integrity of the data
 * Talk to me about how your application is querying the database
   * Indexing criteria
     * What are you frequently searching on?
     * How often are you updating this data?
   * Each time you run a query, SQL Server looks at your query, figures out a good enough way to run it, then caches that in memory
     * If you change *anything*, it looks like a completely new query and it'll go through that process all over again
     * A single space will double the RAM usage and burn CPU while recompiling
     * From your application, different criteria in a plain string will stuff the plan cache
     * Solution: Parameterized queries at least. Preferably stored procedures
       * stored procedures will let us tune queries without having to update the application. Abstraction is helpful!
     * Direct queries vs. stored procs vs. prepared statements
     * Demo: impact on plan cache for each
 * Stored proc - include debug and verify modes
 * Come to me with your queries and let's work through them together 

## Inefficiencies

 * Why do we care?
   * Memory's cheap, but SQL Server has memory limits on everything but Enterprise Edition
   * CPUs have *lots* of cores (up to 72), but again - licensing limits
 * Write a good WHERE clause
   * Don't filter in the app, be as specific as possible when telling SQL Server what you want
   * HME example - one property, copy/paste Excel vs. WHERE (20 seconds vs. sub-second)
   * SARGability
   * We don't want to saturate or wait for the network
 * Give SQL Server every bit of information possible so that it can make a good decision
   * The more SQL Server knows about your data, the less work it has to do
 * Solution: Know your indexes, know your data types, know your relationships

## Accuracy & Speed
 * DISTINCT is a code smell
   * Usually a bad/incomplete JOIN
 * TOP may be misunderstood
   * Still has to do all the work
   * Unless you specify an ORDER, you don't know what you'll get
 * NOLOCK is not a Turbo button!
   * There are places it's OK to use. We can talk about it
 * Don't sort data when it's being inserted. It doesn't matter
 * table variables vs. temp tables
 * Loops/cursors
   * In most cases, if you find yourself saying "for each record I have here, I need to do X" you're probably wrong
   * Demo: update with getdate() in loop vs. a set
   * They do have their place though. I have a 24" Crescent wrench in my garage and I don't use it all the time. But when I need it, I'm glad I've got it.
   * 

## Style
 * CTEs aren't a magic bullet
 * Alias your table names wisely