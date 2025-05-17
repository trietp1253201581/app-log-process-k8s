@echo off
set NAMESPACE=applog
kubectl apply -f k8s/kafka/zookeeper.yaml -n %NAMESPACE%