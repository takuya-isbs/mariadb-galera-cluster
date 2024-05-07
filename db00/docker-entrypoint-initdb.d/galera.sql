
--- https://mariadb.com/kb/en/mariabackup-sst-method/

--- not work?

/* CREATE USER '@MARIA_BACKUP_ACCOUNT@'@'localhost' IDENTIFIED BY '@MARIA_BACKUP_PASSWORD@'; */
/* GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO '@MARIA_BACKUP_ACCOUNT@'@'localhost'; */

CREATE USER 'mariabackup'@'127.0.0.1' IDENTIFIED BY 'pass123';
--- GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@'localhost';
--- GRANT RELOAD, PROCESS, LOCK TABLES, BINLOG MONITOR ON *.* TO 'mariabackup'@'localhost';

GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT, BINLOG MONITOR ON *.* TO 'mariabackup'@'127.0.0.1';

FLUSH PRIVILEGES;
