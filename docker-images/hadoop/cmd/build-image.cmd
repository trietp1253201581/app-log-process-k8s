@echo off
set IMAGENAME=custom-hadoop:latest
set DIR=docker-images/hadoop

docker build -t %IMAGENAME% %DIR%  

docker save %IMAGENAME% -o custom-hadoop.tar  

docker load -i custom-hadoop.tar