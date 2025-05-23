#!/bin/bash
# scripts/linux-sh/hadoop/start-hdfs.sh
NAMESPACE=applog
kubectl apply -f k8s/hadoop/namenode.yaml -n $NAMESPACE

kubectl apply -f k8s/hadoop/datanode.yaml -n $NAMESPACE