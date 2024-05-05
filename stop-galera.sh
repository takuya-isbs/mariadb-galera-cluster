#!/bin/bash

set -eu
set -x

COMPOSE="docker compose"

num_args=$#

if [ $num_args -eq 0 ]; then
  echo "エラー: 最低でも一つの引数を指定してください。"
  exit 1
fi

random_index=$((RANDOM % num_args + 1))
random_choice=${!random_index}

for name in "$@"; do
    if [ "$random_choice" = "$name" ]; then
	continue
    fi
    $COMPOSE stop "$name"
done

sleep 5

# bootstap host
$COMPOSE stop "$random_choice"
