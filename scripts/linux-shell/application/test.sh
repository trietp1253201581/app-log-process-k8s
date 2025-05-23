#!/bin/bash
# scripts/linux-sh/application/test.sh
NAMESPACE=applog
kubectl apply -f k8s/application/consumer-test.yaml -n $NAMESPACE