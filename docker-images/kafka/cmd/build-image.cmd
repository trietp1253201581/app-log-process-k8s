@echo off
set IMAGENAME=custom-kafka:latest
set DIR=docker-images/kafka
set LOCALDIR=tmp/custom-kafka.tar

docker build -t %IMAGENAME% %DIR%  