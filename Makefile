.DEFAULT_GOAL := help
COMPOSE = docker compose

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: init
init: ## make init ## はじめて立ち上げるときに使う(1台立ち上げて、--wsrep-new-clusterコマンドを実行してから残りのDBを立ち上げる)
	$(COMPOSE) build
	sleep 2
	make start

.PHONY: start
start: ## make start ## 2回目以降起動時に使う TODO
	$(COMPOSE) up --no-start
	#TODO ./start.sh  # search 1 from */grastate.dat
	#TODO sudo cat db00_data/grastate.dat | grep ' 1$$'
	$(COMPOSE) --env-file ./new-cluster.env up -d db00
	sleep 1
	$(COMPOSE) up -d db01 db02 db03

.PHONY: stop
stop: ## make stop ## 安全に停止する TODO
	$(COMPOSE) stop db01
	sleep 2
	$(COMPOSE) stop db02
	sleep 2
	$(COMPOSE) stop db03
	sleep 5
	$(COMPOSE) stop db00

.PHONY: ps
ps: ## make ps ## docker compose ps
	$(COMPOSE) ps

.PHONY: logs
logs: ## make logs ## docker compose logs
	$(COMPOSE) logs

.PHONY: logs-f
logs-f: ## make logs ## docker compose logs
	$(COMPOSE) logs -f

.PHONY: shell
shell: ## make logs ## docker compose logs
	$(COMPOSE) exec db00 bash

.PHONY: down
down: ## make down ## docker compose down
	$(COMPOSE) down --remove-orphans

.PHONY: down-v
down-v: ## make down ## docker compose down -v
	$(COMPOSE) down -v --remove-orphans

.PHONY: volume-ls
volume-ls:
	docker volume ls

# .PHONY: rmall
# rmall: ## make rmall ## docker rm -f ${Galera_Cluster_CONTAINERS}
# 	docker ps -a | grep maria | awk '{print $1}' | xargs docker rm -f

.PHONY: show-status
show-status: ## make status ## mysql -u root -e "show status like 'wsrep_cluster_%'"
	$(COMPOSE) exec db00 mysql -u root -e "show status like 'wsrep_cluster_%'"
	$(COMPOSE) exec db01 mysql -u root -e "show status like 'wsrep_cluster_%'"
	$(COMPOSE) exec db02 mysql -u root -e "show status like 'wsrep_cluster_%'"
	$(COMPOSE) exec db03 mysql -u root -e "show status like 'wsrep_cluster_%'"
	$(COMPOSE) exec db00 mysql -u root -e "show status like 'wsrep_local_state_%'"
	$(COMPOSE) exec db01 mysql -u root -e "show status like 'wsrep_local_state_%'"
	$(COMPOSE) exec db02 mysql -u root -e "show status like 'wsrep_local_state_%'"
	$(COMPOSE) exec db03 mysql -u root -e "show status like 'wsrep_local_state_%'"

.PHONY: error
error: ## make error ## docker compose logs | grep [ERROR|WARN|fail] | tail
	$(COMPOSE) logs | grep ERROR | tail
	$(COMPOSE) logs | grep WARN | tail
	$(COMPOSE) logs | grep fail | tail

.PHONY: bench
bench: ## make bench ## docker compose exec db00 bench
	$(COMPOSE) exec db00 bench

.PHONY: backup
backup:
	# TODO
	mkdir -p BACKUP
	docker compose run --volume `pwd`/BACKUP:/backup --rm db00 mariadb-backup --help

#TODO init-from-backup
