@echo off
set NAMESPACE=applog

kubectl apply -f k8s/application/consumer-test.yaml -n %NAMESPACE%