@echo off
set NAMESPACE=applog
set CONFIGNAME=spark-streaming-job
set CONFIGFILEDIR=docker-images/spark/scripts

kubectl delete configmap %CONFIGNAME% -n %NAMESPACE%

kubectl create configmap %CONFIGNAME% --from-file=%CONFIGFILEDIR% -n %NAMESPACE%
