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
$
```

## License
Copyright (c) 2021 [gkz](https://gkz.mit-license.org/2021)

Licensed under the [MIT license](LICENSE).

Unless attributed otherwise, everything is under the MIT licence. Some stuff is not from me, and without attribution, and I no longer remember where I got it from. I apologize for that.