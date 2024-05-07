#!/bin/sh

set -eu
set -x

NAME="$1"

COMPOSE="docker compose"

$COMPOSE rm --stop --force $NAME

# not work : $COMPOSE rm --volumes --force $NAME
VOLUME_PREFIX=$($COMPOSE ls | grep ${PWD}/docker-compose.yml  | awk '{print $1}')

docker volume rm ${VOLUME_PREFIX}_data_${NAME}

$COMPOSE up -d $NAME
