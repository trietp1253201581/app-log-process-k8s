#!/bin/bash
# scripts/linux-sh/application/stop-app.sh
NAMESPACE=applog
kubectl delete -f k8s/application/sim-application.yaml -n $NAMESPACE