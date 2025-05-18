@echo off
set NAMESPACE=applog
kubectl apply -f k8s/application/sim-application.yaml -n %NAMESPACE%