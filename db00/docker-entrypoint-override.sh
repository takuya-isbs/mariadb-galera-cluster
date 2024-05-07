#!/bin/sh

set -eu
set -x

# SEE ALSO: https://github.com/MariaDB/mariadb-docker/blob/d7a950d41e9347ac94ad2d2f28469bff74858db7/10.6/docker-entrypoint.sh

WSREP_NEW_CLUSTER=${WSREP_NEW_CLUSTER:-no}

if [ $WSREP_NEW_CLUSTER = "yes" ]; then
    set -- "$@" --wsrep-new-cluster
fi

sed 's/@wsrep_node_address@/'"$HOSTNAME"'/g' \
    /galera.cnf.tmpl > /etc/mysql/conf.d/galera.cnf

# log for debug
ls -la /var/lib/mysql/

exec "$@"
