#!/usr/bin/env bash
CWD="$(dirname "$0")"
cd "$CWD"

# Not everyone want the existing folder name as prefixes for the container names
# This way of starting up with docker-compose with use "rpt" for the container
# prefix instead of "phs-docker-jaspersoft" because it sets the docker project
# name with the -p flag
docker-compose -p rpt up