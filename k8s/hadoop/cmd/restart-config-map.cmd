@echo off
set NAMESPACE=applog
set CONFIGNAME=hadoop-config
set CONFIGFILEDIR=docker-images/hadoop/config

kubectl delete configmap %CONFIGNAME% -n %NAMESPACE%

kubectl create configmap %CONFIGNAME% --from-file=%CONFIGFILEDIR% -n %NAMESPACE%
