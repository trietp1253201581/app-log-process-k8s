#!/bin/bash
# scripts/linux-sh/kafka/start-kafka-broker.sh
NAMESPACE=applog
kubectl apply -f k8s/kafka/broker.yaml -n $NAMESPACE