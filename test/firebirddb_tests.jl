# -*- coding: utf-8 -*-

import FirebirdDB

println("Testing FirebirdDB")
fb = FirebirdDB.connect("testdb1", "sysdba", "password")
println(fb != nothing ? fb.cn :  fb)
@test fb != nothing
@test FirebirdDB.close(fb)
println(fb.cn)
println("ok")
