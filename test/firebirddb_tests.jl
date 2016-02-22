# -*- coding: utf-8 -*-

import FirebirdDB

println("Testing FirebirdDB")
cn = FirebirdDB.connect("c:/firebird/testdb1.fdb", "sysdba", "password")
println(cn)
@test cn != nothing
@test FirebirdDB.close(cn)
println("ok")
