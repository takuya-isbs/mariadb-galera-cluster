#!/bin/bash
if ! test -e /tmp/lock; then
  mysql -e "create database sbtest;"
  mysql -e "GRANT ALL ON sbtest.* TO 'sbtest'@'127.0.0.1' IDENTIFIED BY 'sbtest';"
  sysbench /usr/share/sysbench/oltp_read_write.lua --db-driver=mysql --table-size=1000000 --mysql-host=127.0.0.1 --mysql-password=sbtest --time=60 --db-ps-mode=disable prepare
  touch /tmp/lock
fi

sysbench /usr/share/sysbench/oltp_read_write.lua --db-driver=mysql --table-size=100000 --mysql-host=127.0.0.1 --mysql-password=sbtest --time=60 --db-ps-mode=disable --threads=8 run