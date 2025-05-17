@echo off
set NAMESPACE=applog
set NUM_DATANODE=2
kubectl delete -f k8s/hadoop/namenode-statefulset.yaml -n %NAMESPACE%

kubectl delete -f k8s/hadoop/datanode-statefulset.yaml -n %NAMESPACE%
