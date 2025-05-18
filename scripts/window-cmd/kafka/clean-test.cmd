@echo off
set NAMESPACE=applog

kubectl delete -f k8s/kafka/producer-test.yaml -n %NAMESPACE%

kubectl delete -f k8s/kafka/consumer-test.yaml -n %NAMESPACE%