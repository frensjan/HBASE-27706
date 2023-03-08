#!/usr/bin/env bash

function hbase_shell {
  SERVER=$(docker compose ps | grep -iE '(running|up)' | grep region-server | shuf -n 1 | awk '{ print $1}')
  docker compose exec "$SERVER" bash -c "echo \"$1\" | hbase shell -n"
}

function hbase {
  SERVER=$(docker compose ps | grep -iE '(running|up)' | grep region-server | shuf -n 1 | awk '{ print $1}')
  docker compose exec "$SERVER" hbase $@
}
