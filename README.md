FirebirdDB
==========

FirebirdDB is a connector to Firebird Database Server.


# setup

```julia
edit c:/Firebird/Firebird_2_1/aliases.conf
testdb1 = c:/Firebird/testdb1.fdb

> c:
> cd c:/Firebird/Firebird_2_1/bin
> gsec -user sysdba -password masterkey
GSEC> display
GSEC> quit
> gsec -user sysdba -password masterkey -mo sysdba -pw ********
> gsec -user sysdba -password masterkey
Your user name and password are not defined.
Ask your database administrator to set up a Firebird login.
unable to open database
> gsec -user sysdba -password ********
GSEC> quit
> isql
Use CONNECT or CREATE DATABASE to specify a database
SQL> create database 'c:/Firebird/testdb1.fdb' user 'sysdba' password '********' page_size=16384 default character set UTF8;
SQL> show database;
Database: c:/Firebird/testdb1.fdb
        Owner: SYSDBA
PAGE_SIZE 16384
Number of DB pages allocated = 154
Sweep interval = 20000
Forced Writes are ON
Transaction - oldest = 1
Transaction - oldest active = 2
Transaction - oldest snapshot = 2
Transaction - Next = 6
ODS = 11.1
Default Character set: UTF8
SQL> quit;
> isql
Use CONNECT or CREATE DATABASE to specify a database
SQL> connect testdb1 user 'sysdba' password '********';
Database:  testdb1, User: sysdba
SQL> show database;
Database: testdb1
        Owner: SYSDBA
PAGE_SIZE 16384
Number of DB pages allocated = 154
Sweep interval = 20000
Forced Writes are ON
Transaction - oldest = 8
Transaction - oldest active = 9
Transaction - oldest snapshot = 9
Transaction - Next = 12
ODS = 11.1
Default Character set: UTF8
SQL> quit;
```


# status

[![Build Status](https://travis-ci.org/HatsuneMiku/FirebirdDB.jl.svg?branch=master)](https://travis-ci.org/HatsuneMiku/FirebirdDB.jl)
