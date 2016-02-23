# -*- coding: utf-8 -*-

import FirebirdDB

println("Testing FirebirdDB")
fb = FirebirdDB.connect("testdb1", "sysdba", "password")
println(fb != nothing ? fb.cn :  fb)
@test fb != nothing
@test FirebirdDB.in_transaction(fb, "drop table ttest;")
@test FirebirdDB.in_transaction(fb,
  "create table ttest (id integer, c1 varchar(10), c2 varchar(20));")
@test FirebirdDB.in_transaction(fb,
  "insert into ttest (id, c1, c2) values (1, 'ABC', 'XYZ');")
@test FirebirdDB.in_transaction(fb,
  "insert into ttest (id, c1, c2) values (2, '222', '000');")
@test FirebirdDB.in_transaction(fb,
  "insert into ttest (id, c1, c2) values (4, '333', 'xyz');")
@test FirebirdDB.in_transaction(fb,
  "insert into ttest (id, c1, c2) values (11, 'ABC', 'XYZ');")
@test FirebirdDB.in_transaction(fb,
  "insert into ttest (id, c1, c2) values (22, '222', '000');")
@test FirebirdDB.in_transaction(fb,
  "delete from ttest where c2 in ('abc', 'def', 'xyz');")
@test FirebirdDB.close(fb)
println(fb.cn)
println("ok")
