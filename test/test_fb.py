#!/usr/local/bin/python
# -*- coding: utf-8 -*-
'''test_fb
'''

import sys, os
import datetime
import kinterbasdb

DBNAME = 'c:/Firebird/testdb1.fdb'
DBUSER = 'sysdba'
DBPASS = 'password'
DBCHAR = 'UTF8'

if not kinterbasdb.initialized:
  kinterbasdb.init(type_conv=200, concurrency_level=1)

def test_fb():
  cn = kinterbasdb.connect(
    dsn=DBNAME, user=DBUSER, password=DBPASS, charset=DBCHAR)
  cur = cn.cursor()
  cur.execute('''insert into ttest (id, c1, c2) values (3, 'xyz', 'abc');''')
  cur.execute('''insert into ttest (id, c1, c2) values (3, 'abc', 'xyz');''')
  cur.execute('''insert into ttest (id, c1, c2) values (3, 'bbb', 'aaa');''')
  cn.commit()
  cur.execute('''select * from ttest;''')
  for row in cur.fetchall():
    print row
  cur.close()
  cn.close()

if __name__ == '__main__':
  test_fb()
