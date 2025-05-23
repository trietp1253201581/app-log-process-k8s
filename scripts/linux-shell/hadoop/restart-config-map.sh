#!/bin/bash
# scripts/linux-sh/hadoop/restart-config-map.sh
NAMESPACE=applog
CONFIGNAME=hadoop-config
CONFIGFILEDIR=docker-images/hadoop/config

kubectl delete configmap $CONFIGNAME -n $NAMESPACE

kubectl create configmap $CONFIGNAME --from-file=$CONFIGFILEDIR -n $NAMESPACE