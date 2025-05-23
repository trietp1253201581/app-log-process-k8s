#!/bin/bash
# scripts/linux-sh/build-all-images.sh
docker build -t custom-hadoop:latest docker-images/hadoop 
docker build -t custom-kafka:latest docker-images/kafka
docker build -t sim-app:latest docker-images/application
docker build -t custom-spark:latest docker-images/spark