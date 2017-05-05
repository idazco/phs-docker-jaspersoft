#!/usr/bin/env bash

CWD="$(dirname "$0")"
cd "$CWD"

function missing_info_death() {
    echo "[ERROR] can't continue with missing info"
    exit 1
}

DB_PORT=5432
read -e -p "Postgres DB port exposed on host ---> " -i "$DB_PORT" DB_PORT
if [ "$DB_PORT" == "" ]; then
    missing_info_death
fi

DB_USER="jasper"
read -e -p "JasperServer DB user ---> " -i "$DB_USER" DB_USER
if [ "$DB_USER" == "" ]; then
    missing_info_death
fi

DB_PASS="jasper"
read -e -p "JasperServer DB password ---> " -i "$DB_PASS" DB_PASS
if [ "$DB_PASS" == "" ]; then
    missing_info_death
fi

docker run -d --name jasper-db \
-e POSTGRES_USER="$DB_USER" \
-e POSTGRES_PASSWORD="$DB_PASS" \
-p "$DB_PORT":5432 \
sylnsr/postgres-ssl:9.4
# For transparency sake: github.com/sylnsr/docker-postgres-ssl
# Uses the official Postgres image with SSL
