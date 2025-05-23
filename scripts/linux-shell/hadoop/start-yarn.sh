#!/bin/bash
# scripts/linux-sh/hadoop/start-yarn.sh
NAMESPACE=applog
NUM_DATANODE=2
kubectl apply -f k8s/hadoop/resourcemanager.yaml -n $NAMESPACE

kubectl apply -f k8s/hadoop/nodemanager.yaml -n $NAMESPACE