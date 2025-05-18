@echo off
set NAMESPACE=applog
kubectl apply -f k8s/kafka/broker.yaml -n %NAMESPACE%