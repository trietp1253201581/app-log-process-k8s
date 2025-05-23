#!/bin/bash
# scripts/linux-sh/application/clean-test.sh
NAMESPACE=applog
kubectl delete -f k8s/application/consumer-test.yaml -n $NAMESPACE