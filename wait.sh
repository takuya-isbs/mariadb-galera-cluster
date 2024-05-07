#!/bin/sh

NAME="$1"

while ! docker compose exec $NAME mariadb -u root -e "SELECT 1" 2>/dev/null; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

echo "MariaDB is ready for connections!"
