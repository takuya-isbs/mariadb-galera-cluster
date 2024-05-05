#!/bin/sh

set -eu
set -x

CONTNAME="$1"

COMPOSE="docker compose"

is_up() {
    N=$($COMPOSE ps "$1" | wc -l)
    [ $N -eq 1 ]
}

is_up $CONTNAME
$COMPOSE stop $CONTNAME

#TODO ?volume?
VOL="./${CONTNAME}_data/"

rm -rf "$VOL"
mkdir "$VOL"

$COMPOSE up -d $CONTNAME
