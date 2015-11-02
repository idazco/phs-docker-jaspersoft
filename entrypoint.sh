#!/bin/bash
set -e

# wait for a given host:port to become available
#
# $1 host
# $2 port
function dockerwait {
    while ! exec 6<>/dev/tcp/$1/$2; do
        echo "$(date) - waiting to connect $1 $2"
        sleep 5
    done
    echo "$(date) - connected to $1 $2"

    exec 6>&-
    exec 6<&-
}


# wait for services to become available
# this prevents race conditions using fig
function wait_for_services {
    if [[ "$WAIT_FOR_DB" ]] ; then
        dockerwait $DB_HOST $DB_PORT
    fi
}

wait_for_services

# Get the DB_HOST and DB_PORT from docker linking if not set
# TODO: Add support for other DBs
: ${DB_HOST:=${DATABASE_PORT_5432_TCP_ADDR}}
: ${DB_PORT:=${DATABASE_PORT_5432_TCP_PORT}}
: ${DB_NAME:="jasperserver"}

# Make corrections in /usr/local/tomcat/webapps/jasperserver/META-INF/context.xml
sed -i "s/db_host_to_replace/$DB_HOST/g; s/db_port_to_replace/$DB_PORT/g; s/db_name_to_replace/$DB_NAME/g; s/db_username_to_replace/$DB_USERNAME/g; s/db_password_to_replace/$DB_PASSWORD/g" /usr/local/tomcat/webapps/ROOT/META-INF/context.xml

# Also make corrections in /usr/src/jasperreports-server/buildomatic/default_master.properties for tools
sed -i -e "s|^dbHost.*$|dbHost=$DB_HOST|g; s|^dbPort.*$|dbPort=$DB_PORT|g; s|^js\.dbName.*$|js\.dbName=$DB_NAME|g; s|^dbUsername.*$|dbUsername=$DB_USERNAME|g; s|^dbPassword.*$|dbPassword=$DB_PASSWORD|g" /usr/src/jasperreports-server/buildomatic/default_master.properties

if [ "$1" = 'development' ]; then
    db-initialize.sh --skip-create
    catalina.sh run
    exit $?
fi

echo "[RUN]: Builtin command not provided [development]"
echo "[RUN]: $@"

# Run the passed in command
exec "$@"
