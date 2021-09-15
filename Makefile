.DEFAULT_GOAL := help


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: init
init: ## make init
	docker-compose up --no-start
	sleep 2
	docker-compose start db00
	docker-compose start db01 db02 db03
	sleep 3

.PHONY: up
up: ## make up
	docker-compose up -d

.PHONY: ps
ps: ## make ps
	docker-compose ps

.PHONY: exec0
exec0: ## make exec0
	#docker-compose exec node0 mysql -u root -p
	docker-compose exec node0 mysql -u root

.PHONY: exec1
exec1: ## make exec1
	#docker-compose exec node1 mysql -u root -p
	docker-compose exec node1 mysql -u root

.PHONY: exec2
exec2: ## make exec2
	#docker-compose exec node2 mysql -u root -p
	docker-compose exec node2 mysql -u root

.PHONY: exec3
exec3: ## make exec3
	#docker-compose exec node3 mysql -u root -p
	docker-compose exec node3 mysql -u root

.PHONY: logs0
logs0: ## make logs0
	docker-compose logs db00

.PHONY: logs1
logs1: ## make logs1
	docker-compose logs db01

.PHONY: logs2
logs2: ## make logs2
	docker-compose logs db02

.PHONY: logs3
logs3: ## make logs3
	docker-compose logs db03

.PHONY: stop0
stop0: ## make stop0
	docker-compose stop db00

.PHONY: stop1
stop1: ## make stop1
	docker-compose stop db01

.PHONY: stop2
stop2: ## make stop2
	docker-compose stop db02

.PHONY: stop3
stop3: ## make stop3
	docker-compose stop db03

.PHONY: down
down: ## make down
	docker-compose down -v

.PHONY: rmall
rmall: ## make rmall
	docker ps -a | grep maria | awk '{print $1}' | xargs docker rm -f


.PHONY: show
show: ## make show
	docker-compose exec db00 mysql -u root -e "show status like 'wsrep_cluster_%'"
	docker-compose exec db00 mysql -u root -e "show status like 'wsrep_local_state_%'"
	docker-compose exec db01 mysql -u root -e "show status like 'wsrep_local_state_%'"
	docker-compose exec db02 mysql -u root -e "show status like 'wsrep_local_state_%'"
	docker-compose exec db03 mysql -u root -e "show status like 'wsrep_local_state_%'"


.PHONY: error
error: ## make error
	docker-compose logs | grep ERROR | tail
	docker-compose logs | grep WARN | tail
	docker-compose logs | grep fail | tail