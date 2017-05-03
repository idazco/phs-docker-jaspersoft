#!/usr/bin/env bash

docker run -d --name jasper-db \
-e POSTGRES_USER=jasperapp \
-e POSTGRES_PASSWORD=jasperapp \
-p 5431:5432 \
sylnsr/postgres-ssl:9.4
# For transparency sake: github.com/sylnsr/docker-postgres-ssl
# Uses the official Postgres image with SSL
