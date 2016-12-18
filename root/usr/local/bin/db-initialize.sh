#!/bin/bash
set -e

# HACK: The db.template.properties has &amp; for tomcat, but needs to change to & for this
sed -i 's/\&amp;/\&/g' ${JASPER_SRC}/buildomatic/conf_source/db/postgresql/db.template.properties

pushd ${JASPER_SRC}/buildomatic
if [[ ! "$1" == "--skip-create" ]]; then
  ./js-ant create-js-db
fi
./js-ant init-js-db-ce
./js-ant import-minimal-ce
popd
