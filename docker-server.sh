#!/usr/bin/env bash

docker run -d --name jasper-server \
-p 8080:8080 \
-e DB_HOST=db \
-e DB_PORT=5432 \
-e DB_NAME=jasperapp \
-e DB_USERNAME=jasperapp \
-e DB_PASSWORD=jasperapp \
-e WAIT_FOR_DB=1 \
--link jasper-db:db \
--add-host hostos:10.0.0.104 \
sylnsr/jasper-server development