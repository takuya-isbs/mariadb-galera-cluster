#!/bin/sh

set -eu
set -x

COMPOSE="docker compose"

is_bootstrap() {
    if $COMPOSE run -it --rm "$1" cat /var/lib/mysql/grastate.dat | grep -q '^safe_to_bootstrap: 1'; then
	return 0
    else
	return 1
    fi
}

select_bootstrap() {
    for name in "$@"; do
	if is_bootstrap $name; then
	    echo "$name"
	    return 0
	fi
    done
    echo ""
    return 1
}

BOOTSTRAP=$(select_bootstrap "$@")
if [ "$BOOTSTRAP" = "" ]; then
    exit 1
fi

echo $BOOTSTRAP

$COMPOSE --env-file ./new-cluster.env up -d $BOOTSTRAP
sleep 2

for name in "$@"; do
    if [ "$BOOTSTRAP" = "$name" ]; then
	continue
    fi
    $COMPOSE up -d "$name"
done
