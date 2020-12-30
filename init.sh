#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Error: Please run as root." >&2
  exit 1
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

echo "### Checking for 'web' docker network"
NETSCAN=$(docker network inspect web -f '{{.Name}} - {{.Driver}}' 2>&1)
if [[ "$NETSCAN" == *"No such network"* ]]; then
  docker network create web
else
  echo $NETSCAN "OK"
fi
echo

echo "### Checking for 'db' docker network"
NETSCAN=$(docker network inspect db -f '{{.Name}} - {{.Driver}}' 2>&1)
if [[ "$NETSCAN" == *"No such network"* ]]; then
  docker network create db
else
  echo $NETSCAN "OK"
fi
echo

echo "### Checking for 'mariadb_data' docker volume"
VOLSCAN=$(docker volume inspect mariadb_data -f '{{.Name}} - {{.Driver}}' 2>&1)
if [[ "$VOLSCAN" == *"No such volume"* ]]; then
  docker volume create mariadb_data
else
  echo $VOLSCAN "OK"
fi
echo

echo "### Starting services"
docker-compose up -d
echo
