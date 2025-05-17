#!/bin/bash
export KAFKA_CFG_ZOOKEEPER_CONNECT=${KAFKA_ZOOKEEPER_CONNECT:-zookeeper:2181}
export KAFKA_CFG_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-PLAINTEXT://kafka:9092}
export KAFKA_CFG_LISTENERS=${KAFKA_LISTENERS:-PLAINTEXT://0.0.0.0:9092}

exec /opt/bitnami/scripts/kafka/entrypoint.sh /opt/bitnami/scripts/kafka/run.sh