# Updated version of mariadb-galera-cluster

## Forked from

https://github.com/gkzz/mariadb-galera-cluster

## Copyright of this updates

Copyright (c) 2024 takuya-isbs

https://github.com/takuya-isbs

## 目的

- 参考: https://github.com/gkzz/mariadb-galera-cluster
  - 参考になりました。(感謝)
  - これをベースに Galera Cluster を勉強する。
- 停止・再開処理を追加
- 障害・復旧を想定した処理を追加
- Docker イメージを共通化

## 使い方

- 新規起動
  - make init
  - make show-status
  - make bench
    - 動作確認

- 停止・再開
  - make stop
    - ランダムな順序で停止される。
    - 最後に停止されたコンテナの bootstrap が 1 になる。
    - NOTE: 同時に停止すると galera cluster が破損する。
  - make start
    - bootstrap が 1 のコンテナから起動される。
  - make show-status
  - make bench

- バックアップ
  - make backup
    - mariadb-dump でバックアップされる。
  - make bench
    - 動作確認

- すべて破棄
  - make down-v
    - Docker ボリューム領域に保存された DB データも削除される。

- リストア
  - バックアップしておく。
  - make down-v ですべて破棄しておく。
  - 戻したい ./BACKUP/backup-?.sql.gz を決める。
  - cp ./BACKUP/backup-?.sql.gz ./mariadb-backup.sql.gz
  - make restore-init
  - make show-status
  - make bench

- 個別に破壊・再所属
  - ./test-destroy-and-join.sh コンテナ名
    - volume を削除してからコンテナを再構築される。
  - make show-status
  - make bench

- シェル
  - make shell-db00
  - make shell-db01
  - make shell-db02
  - make shell-db03

## メモ

- mariadb コマンドと mysql コマンドは同じ
- mariabackup によるバックアップがなぜかエラー
