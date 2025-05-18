@echo off
set NAMESPACE=applog
kubectl delete -f k8s/application/sim-application.yaml -n %NAMESPACE%