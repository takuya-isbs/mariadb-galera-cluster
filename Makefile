.DEFAULT_GOAL := help


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: init
init: ## make init ## はじめて立ち上げるときに使う(1台立ち上げて、--wsrep-new-clusterコマンドを実行してから残りのDBを立ち上げる)
	docker-compose up --no-start
	sleep 2
	docker-compose start db00
	docker-compose start db01 db02 db03
	sleep 3

.PHONY: up
up: ## make up ## docker-compose up -d(全台立ち上げている場合のみ使う)
	docker-compose up -d

.PHONY: ps
ps: ## make ps ## docker-compose ps
	docker-compose ps

.PHONY: logs
logs: ## make logs ## docker-compose logs
	docker-compose logs

.PHONY: down
down: ## make down ## docker-compose down -v
	docker-compose down -v

.PHONY: rmall
rmall: ## make rmall ## docker rm -f ${Galera_Cluster_CONTAINERS}
	docker ps -a | grep maria | awk '{print $1}' | xargs docker rm -f


.PHONY: show
show: ## make show ## mysql -u root -e "show status like 'wsrep_cluster_%'"
	docker-compose exec db00 mysql -u root -e "show status like 'wsrep_cluster_%'"
	docker-compose exec db00 mysql -u root -e "show status like 'wsrep_local_state_%'"
	docker-compose exec db01 mysql -u root -e "show status like 'wsrep_local_state_%'"
	docker-compose exec db02 mysql -u root -e "show status like 'wsrep_local_state_%'"
	docker-compose exec db03 mysql -u root -e "show status like 'wsrep_local_state_%'"


.PHONY: error
error: ## make error ## docker-compose logs | grep [ERROR|WARN|fail] | tail
	docker-compose logs | grep ERROR | tail
	docker-compose logs | grep WARN | tail
	docker-compose logs | grep fail | tail

.PHONY: bench
bench: ## make bench ## docker-compose exec db00 bench
	docker-compose exec db00 bench