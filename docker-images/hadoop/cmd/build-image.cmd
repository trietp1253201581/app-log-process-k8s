@echo off
set IMAGENAME=custom-hadoop:latest
set DIR=docker-images/hadoop
set LOCALDIR=tmp/custom-hadoop.tar

docker build -t %IMAGENAME% %DIR%  

docker save %IMAGENAME% -o %LOCALDIR% 

docker load -i %LOCALDIR%