#!/usr/bin/env bash

CWD="$(dirname "$0")"
cd "$CWD"

function missing_info_death() {
    echo "[ERROR] can't continue with missing info"
    exit 1
}

IP_ADDRESS="$(ifconfig | sed -En 's/127.0.0.1//;s/172.17.//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"
read -e -p "Host LAN IP address ---> " -i "$IP_ADDRESS" IP_ADDRESS
if [ "$IP_ADDRESS" == "" ]; then
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

JASPER_PORT=8080
read -e -p "JasperServer port exposed on host ---> " -i "$JASPER_PORT" JASPER_PORT
if [ "$JASPER_PORT" == "" ]; then
    missing_info_death
fi

docker run -d --name jasper-server \
-p "$JASPER_PORT":8080 \
-e DB_HOST=db \
-e DB_NAME=jasper \
-e DB_PORT=5432 \
-e DB_USERNAME="$DB_USER" \
-e DB_PASSWORD="$DB_PASS" \
-e WAIT_FOR_DB=1 \
--link jasper-db:db \
--add-host hostos:"$IP_ADDRESS" \
idazco/jasper-server-ce development

# "hostos" is a helpful alias for setting up data-source connections - use a different alias if you when the DB is not on the same host
# the idazco/jasper-server-ce image is built from this project - use something else if you wish

echo "NOTE: It will take some time for JasperServer to build in container and be available on http://127.0.0.1:$JASPER_PORT"
echo "Please be patient"