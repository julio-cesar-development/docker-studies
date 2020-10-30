#!/bin/sh

set -e

mysql -sN \
  -h $MYSQL_HOST \
  -P $MYSQL_PORT \
  -u $MYSQL_USER \
  -p$MYSQL_PASS \
  -D $MYSQL_DATABASE -e \
  "SELECT * FROM USER"

echo "[INFO] APP v2 Success"
