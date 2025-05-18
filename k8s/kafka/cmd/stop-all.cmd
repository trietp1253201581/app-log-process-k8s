@echo off
set NAMESPACE=applog
kubectl delete -f k8s/kafka/broker.yaml -n %NAMESPACE%
kubectl delete -f k8s/kafka/zookeeper.yaml -n %NAMESPACE%