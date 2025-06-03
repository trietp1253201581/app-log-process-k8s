#!/bin/bash

set -e

echo "Starting Hive container with role: $HIVE_ROLE"

# Chờ DB sẵn sàng
until nc -z -v -w30 hive-metastore-db 5432; do
  echo "Waiting for PostgreSQL at hive-metastore-db:5432..."
  sleep 5
done

case "$HIVE_ROLE" in
  metastore)
    if [ ! -f /check/metastore-initialized ]; then
      echo "Initializing metastore schema..."
      schematool -dbType postgres -initSchema
      touch /check/metastore-initialized
    else
      echo "Metastore schema already initialized, skipping."
    fi
    echo "Starting Hive Metastore..."
    exec hive --service metastore
    ;;
  server2)
    echo "Starting HiveServer2..."
    exec hiveserver2
    ;;
  *)
    echo "Unknown HIVE_ROLE: $HIVE_ROLE"
    exit 1
    ;;
esac
