#!/bin/bash
# scripts/linux-sh/kafka/test.sh
NAMESPACE=applog

kubectl apply -f k8s/kafka/producer-test.yaml -n $NAMESPACE

kubectl apply -f k8s/kafka/consumer-test.yaml -n $NAMESPACE