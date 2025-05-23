#!/bin/bash
# scripts/linux-sh/kafka/start-zookeeper.sh
NAMESPACE=applog
kubectl apply -f k8s/kafka/zookeeper.yaml -n $NAMESPACE