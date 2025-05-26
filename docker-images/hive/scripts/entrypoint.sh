#!/bin/bash

# Chờ Metastore DB sẵn sàng (PostgreSQL)
until nc -z -v -w30 hive-metastore-db 5432; do
  echo "Waiting for PostgreSQL at hive-metastore-db:5432..."
  sleep 5
done

# Khởi tạo Metastore schema nếu chưa có
schematool -dbType postgres -initSchema || echo "Schema already exists"

# Chạy dịch vụ Hive
if [[ "$HIVE_ROLE" == "metastore" ]]; then
  hive --service metastore
elif [[ "$HIVE_ROLE" == "server2" ]]; then
  hiveserver2
fi
