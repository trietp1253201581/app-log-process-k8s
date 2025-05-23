#!/bin/bash
# scripts/linux-sh/kafka/clean-test.sh
NAMESPACE=applog

kubectl delete -f k8s/kafka/producer-test.yaml -n $NAMESPACE

kubectl delete -f k8s/kafka/consumer-test.yaml -n $NAMESPACE