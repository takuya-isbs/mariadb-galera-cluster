# MariaDB Galera Cluster on docker-compose

**This is an `experimental` repository to familiarize myself with MariaDB Galera Cluster**.

## TL;DR

```
$ make init
docker-compose up --no-start
Creating network "mariadb-galera-cluster_db_network" with driver "bridge"
Creating volume "mariadb-galera-cluster_db00_data" with default driver
Creating volume "mariadb-galera-cluster_db01_data" with default driver
Creating volume "mariadb-galera-cluster_db02_data" with default driver
Creating volume "mariadb-galera-cluster_db03_data" with default driver
Creating db01 ... done
Creating db00 ... done
Creating db03 ... done
Creating db02 ... done
sleep 2
docker-compose start db00
Starting db00 ... done
docker-compose start db01 db02 db03
Starting db01 ... done
Starting db02 ... done
Starting db03 ... done
sleep 3
$ make ps
docker-compose ps
Name              Command               State                                                 Ports                                               
--------------------------------------------------------------------------------------------------------------------------------------------------
db00   docker-entrypoint.sh --wsr ...   Up      0.0.0.0:3306->3306/tcp, 0.0.0.0:4444->4444/tcp, 0.0.0.0:4567->4567/tcp, 0.0.0.0:4568->4568/tcp    
db01   docker-entrypoint.sh mysqld      Up      0.0.0.0:13306->3306/tcp, 0.0.0.0:14444->4444/tcp, 0.0.0.0:14567->4567/tcp, 0.0.0.0:14568->4568/tcp
db02   docker-entrypoint.sh mysqld      Up      0.0.0.0:23306->3306/tcp, 0.0.0.0:24444->4444/tcp, 0.0.0.0:24567->4567/tcp, 0.0.0.0:24568->4568/tcp
db03   docker-entrypoint.sh mysqld      Up      0.0.0.0:33306->3306/tcp, 0.0.0.0:34444->4444/tcp, 0.0.0.0:34567->4567/tcp, 0.0.0.0:34568->4568/tcp
$ make show
docker-compose exec db00 mysql -u root -e "show status like 'wsrep_cluster_%'"
+----------------------------+--------------------------------------+
| Variable_name              | Value                                |
+----------------------------+--------------------------------------+
| wsrep_cluster_weight       | 4                                    |
| wsrep_cluster_capabilities |                                      |
| wsrep_cluster_conf_id      | 2                                    |
| wsrep_cluster_size         | 4                                    |
| wsrep_cluster_state_uuid   | bc072429-149a-11ec-8718-9b1fede91861 |
| wsrep_cluster_status       | Primary                              |
+----------------------------+--------------------------------------+
docker-compose exec db00 mysql -u root -e "show status like 'wsrep_local_state_%'"
+---------------------------+--------------------------------------+
| Variable_name             | Value                                |
+---------------------------+--------------------------------------+
| wsrep_local_state_uuid    | bc072429-149a-11ec-8718-9b1fede91861 |
| wsrep_local_state_comment | Synced                               |
+---------------------------+--------------------------------------+
docker-compose exec db01 mysql -u root -e "show status like 'wsrep_local_state_%'"
+---------------------------+--------------------------------------+
| Variable_name             | Value                                |
+---------------------------+--------------------------------------+
| wsrep_local_state_uuid    | bc072429-149a-11ec-8718-9b1fede91861 |
| wsrep_local_state_comment | Synced                               |
+---------------------------+--------------------------------------+
docker-compose exec db02 mysql -u root -e "show status like 'wsrep_local_state_%'"
+---------------------------+--------------------------------------+
| Variable_name             | Value                                |
+---------------------------+--------------------------------------+
| wsrep_local_state_uuid    | bc072429-149a-11ec-8718-9b1fede91861 |
| wsrep_local_state_comment | Synced                               |
+---------------------------+--------------------------------------+
docker-compose exec db03 mysql -u root -e "show status like 'wsrep_local_state_%'"
+---------------------------+--------------------------------------+
| Variable_name             | Value                                |
+---------------------------+--------------------------------------+
| wsrep_local_state_uuid    | bc072429-149a-11ec-8718-9b1fede91861 |
| wsrep_local_state_comment | Synced                               |
+---------------------------+--------------------------------------+
$
```

## Technology used

```
$ grep VERSION /etc/os-release 
VERSION="20.04.3 LTS (Focal Fossa)"
VERSION_ID="20.04"
VERSION_CODENAME=focal 
$ docker --version
Docker version 19.03.3, build a872fc2f86
$ docker-compose --version
docker-compose version 1.24.1, build 4667896b
$ grep image docker-compose.yml 
    image: mariadb:10.6.4
    image: mariadb:10.6.4
    image: mariadb:10.6.4
    image: mariadb:10.6.4
$
```

### Tips

```
$ make help
init                 Start one, execute the --wsrep-new-cluster command, and then start the rest of the DB
up                   docker-compose up -d(Only when DBs started up)
ps                   docker-compose ps
logs                 docker-compose logs
down                 docker-compose down -v
rmall                docker rm -f ${Galera_Cluster_CONTAINERS}
show                 mysql -u root -e "show status like 'wsrep_cluster_%'"
error                docker-compose logs | grep [ERROR|WARN|fail] | tail
bench                docker-compose exec db00 bench
```

- Directory structure
```
$ tree -L 3
.
├── db00
│   ├── conf.d
│   │   └── galera.cnf
│   ├── docker-entrypoint-initdb.d
│   │   └── seed.sql
│   ├── Dockerfile
│   └── scripts
│       ├── bench.sh
│       └── my-wsrep-notify.sh
├── db01
│   ├── conf.d
│   │   └── galera.cnf
│   ├── docker-entrypoint-initdb.d
│   │   └── seed.sql
│   └── scripts
│       └── my-wsrep-notify.sh
├── db02
│   ├── conf.d
│   │   └── galera.cnf
│   ├── docker-entrypoint-initdb.d
│   └── scripts
│       └── my-wsrep-notify.sh
├── db03
│   ├── conf.d
│   │   └── galera.cnf
│   ├── docker-entrypoint-initdb.d
│   └── scripts
│       └── my-wsrep-notify.sh
├── docker-compose.yml
├── LICENCE
├── Makefile
└── README.md

16 directories, 16 files
$
```


- sysbench
```
$ make bench
docker-compose exec db00 bench
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 1000000 records into 'sbtest1'
Creating a secondary index on 'sbtest1'...
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Initializing random number generator from current time


Initializing worker threads...

Threads started!

SQL statistics:
    queries performed:
        read:                            120876
        write:                           28317
        other:                           23487
        total:                           172680
    transactions:                        8634   (143.77 per sec.)
    queries:                             172680 (2875.32 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          60.0497s
    total number of events:              8634

Latency (ms):
         min:                                   16.61
         avg:                                   55.63
         max:                                  545.36
         95th percentile:                       75.82
         sum:                               480304.07

Threads fairness:
    events (avg/stddev):           1079.2500/3.46
    execution time (avg/stddev):   60.0380/0.00
$
```

Ref: [MariaDB Galera Clusterを動かしてみた | ten-snapon.com](https://ten-snapon.com/archives/2123)

## License
Copyright (c) 2021 [gkz](https://gkz.mit-license.org/2021)

Licensed under the [MIT license](LICENSE).

Unless attributed otherwise, everything is under the MIT licence. Some stuff is not from me, and without attribution, and I no longer remember where I got it from. I apologize for that.