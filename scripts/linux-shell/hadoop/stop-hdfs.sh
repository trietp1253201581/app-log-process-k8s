#!/bin/bash
# scripts/linux-sh/hadoop/stop-hdfs.sh
NAMESPACE=applog
kubectl delete -f k8s/hadoop/namenode.yaml -n $NAMESPACE

kubectl delete -f k8s/hadoop/datanode.yaml -n $NAMESPACE