.DEFAULT_GOAL := help
COMPOSE = docker compose

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: init
init: ## make init ## はじめて立ち上げるときに使う(1台立ち上げて、--wsrep-new-clusterコマンドを実行してから残りのDBを立ち上げる)
	make init1
	sleep 2
	make init2

.PHONY: init1
init1:
	$(COMPOSE) build
	$(COMPOSE) --env-file ./new-cluster.env up -d db00

.PHONY: init2
init2:
	$(COMPOSE) up -d db01 db02 db03

.PHONY: build
build: ## make build ## 再ビルド
	$(COMPOSE) build

.PHONY: start
start: ## make start2 ## 自動的にbootstrapを探してから起動
	$(COMPOSE) up --no-start
	./start-galera.sh db00 db01 db02 db03

.PHONY: stop
stop: ## make stop ## 安全に停止する TODO
	./stop-galera.sh db00 db01 db02 db03

.PHONY: ps
ps: ## make ps ## docker compose ps
	$(COMPOSE) ps

.PHONY: logs
logs: ## make logs ## docker compose logs
	$(COMPOSE) logs --no-color | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'

.PHONY: logs-db00
logs-db00: ## make logs-db00 ## docker compose logs db00
	$(COMPOSE) logs --no-color db00 | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'

.PHONY: logs-f
logs-f: ## make logs ## docker compose logs -f
	$(COMPOSE) logs -f --no-color | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'

.PHONY: logs-f-db00
logs-f-db00: ## make logs-db00 ## docker compose logs -f db00
	$(COMPOSE) logs -f db00 | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'

.PHONY: shell shell-db00 db00
shell shell-db00 db00: ## make shell ## shell db00
	$(COMPOSE) exec db00 bash

.PHONY: shell-db01 db01
shell-db01 db01: ## make db01 ## shell db01
	$(COMPOSE) exec db01 bash

.PHONY: shell-db02 db02
shell-db02 db02: ## make db02 ## shell db02
	$(COMPOSE) exec db02 bash

.PHONY: shell-db03 db03
shell-db03 db03: ## make db03 ## shell db03
	$(COMPOSE) exec db03 bash

.PHONY: down
down: ## make down ## docker compose down
	$(COMPOSE) down --remove-orphans

.PHONY: down-v
down-v: ## make down-v ## docker compose down -v
	$(COMPOSE) down -v --remove-orphans

.PHONY: volume-ls
volume-ls:
	docker volume ls

.PHONY: network-ls
network-ls:
	docker network ls

# .PHONY: rmall
# rmall: ## make rmall ## docker rm -f ${Galera_Cluster_CONTAINERS}
# 	docker ps -a | grep maria | awk '{print $1}' | xargs docker rm -f

.PHONY: show-status
show-status: ## make status ## mysql -u root -e "show status like 'wsrep_cluster_%'"
	$(COMPOSE) exec db00 mysql -u root -e "show status like 'wsrep_cluster_%'" || true
	$(COMPOSE) exec db01 mysql -u root -e "show status like 'wsrep_cluster_%'" || true
	$(COMPOSE) exec db02 mysql -u root -e "show status like 'wsrep_cluster_%'" || true
	$(COMPOSE) exec db03 mysql -u root -e "show status like 'wsrep_cluster_%'" || true
	$(COMPOSE) exec db00 mysql -u root -e "show status like 'wsrep_local_state_%'" || true
	$(COMPOSE) exec db01 mysql -u root -e "show status like 'wsrep_local_state_%'" || true
	$(COMPOSE) exec db02 mysql -u root -e "show status like 'wsrep_local_state_%'" || true
	$(COMPOSE) exec db03 mysql -u root -e "show status like 'wsrep_local_state_%'" || true
	$(COMPOSE) exec db00 mysql -u root -e "select user,host from user" mysql

.PHONY: error
error: ## make error ## docker compose logs | grep [ERROR|WARN|fail] | tail
	$(COMPOSE) logs | grep ERROR | tail
	$(COMPOSE) logs | grep WARN | tail
	$(COMPOSE) logs | grep fail | tail

.PHONY: bench
bench: ## make bench ## docker compose exec db00 bench
	$(COMPOSE) exec db00 bench

.PHONY: bench-db01
bench-db01: ## make bench-db01 ## docker compose exec db01 bench
	$(COMPOSE) exec db01 bench

.PHONY: backup
backup: ## make backup ## バックアップ
	# REFERENCE: https://mariadb.com/kb/en/container-backup-and-restoration/
	mkdir -p BACKUP
	DT=$$(date +%Y%m%d-%H%M); \
	docker compose exec -i db00 \
	mariadb-dump --single-transaction --all-databases -uroot | gzip > ./BACKUP/backup-$${DT}.sql.gz

.PHONY: restore-init
restore-init: ## make restore-init ## リストア
	make init1
	sh ./wait.sh db00
	sh ./restore.sh
	make init2

.PHONY: mariabackup
mariabackup:
	# TODO not work:
	# [00] 2024-05-07 16:39:48 Connecting to MariaDB server host: localhost, user: mariabackup, password: set, port: 3306, socket: /run/mysqld/mysqld.sock
	# [00] 2024-05-07 16:39:48 Failed to connect to MariaDB server: Access denied for user 'mariabackup'@'::1' (using password: YES).
	mkdir -p BACKUP
	docker compose exec db00 \
	mariabackup -h 127.0.0.1 -P 3306 --protocol=tcp --backup --galera-info --target-dir=/BACKUP \
            --user=mariabackup --password=pass123
