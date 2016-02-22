# -*- coding: utf-8 -*-

import FirebirdDB

println("Testing FirebirdDB")
cn = FirebirdDB.connect("testdb1", "sysdba", "password")
println(cn)
@test cn != nothing
@test FirebirdDB.close(cn)
println("ok")
