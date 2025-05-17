@echo off
set NAMESPACE=applog
set NUM_DATANODE=2
kubectl delete -f k8s/hadoop/resourcemanager.yaml -n %NAMESPACE%

kubectl delete -f k8s/hadoop/nodemanager.yaml -n %NAMESPACE%
