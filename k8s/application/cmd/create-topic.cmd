@echo off
set POD=kafka-broker-0
set NAMESPACE=applog

kubectl exec -n %NAMESPACE% %POD% -- sh -c "kafka-topics.sh --bootstrap-server kafka:9092 --list | grep -q \"^app-logs$\" || kafka-topics.sh --create --topic app-logs --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1"
