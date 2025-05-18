@echo off
set IMAGENAME=sim-app:latest
set DIR=docker-images/application

docker build -t %IMAGENAME% %DIR%  