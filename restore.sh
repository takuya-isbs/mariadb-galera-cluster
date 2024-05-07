#!/bin/sh

set -eu
set -x

BACKUP_FILE=mariadb-backup.sql.gz

if [ ! -f ./$BACKUP_FILE ]; then
    cat <<EOF >&2
## Please select and copy the backup file to ./$BACKUP_FILE
Example: cp ./BACKUP/backup-?.sql.gz ./$BACKUP_FILE

!!!NOTE!!!: ./$BACKUP_FILE will be deleted after the restore process.
EOF
    exit 1
fi

zcat ./$BACKUP_FILE | docker compose exec -T db00 sh -c 'mariadb -uroot'

docker compose exec -T db00 sh -c 'mariadb -uroot -e "FLUSH PRIVILEGES"'

rm -f ./$BACKUP_FILE
