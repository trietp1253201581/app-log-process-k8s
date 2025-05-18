@echo off
set NAMESPACE=applog
kubectl delete -f k8s/application/consumer-test.yaml -n %NAMESPACE%