@echo off
set NAMESPACE=applog
kubectl delete -f k8s/spark/spark-rbac.yaml -n %NAMESPACE%
kubectl delete -f k8s/spark/spark-app.yaml -n %NAMESPACE%
kubectl delete -f k8s/spark/driver.yaml -n %NAMESPACE%
kubectl delete -f k8s/spark/spark-operator.yaml -n %NAMESPACE%