# app-log-process-k8s
 A Big Data System with Hadoop, Spark, Kafka, Hive, dbt to process large log from an application

-----
## Kiến trúc hệ thống
Hệ thống hiện tại sử lý dữ liệu Streaming, luồng dữ liệu chính là
```txt
Application ------> Kafka Topic ------> Spark Streaming ------> HDFS ------> Hive (Query, external table)
```
### Thành phần chính:
- **Application**: Ứng dụng giả lập sinh log (Producer)
- **Kafka**: Message broker để thu thập log real-time
- **Spark Streaming**: Xử lý và transform dữ liệu
- **HDFS**: Lưu trữ dữ liệu dạng Parquet
- **Hive**: Data warehouse cho việc truy vấn
- **dbt**: Data transformation và modeling
### Luồng dữ liệu
- Dữ liệu giả lập log sẽ đi từ ứng dụng (đóng vai trò producer) sau đó gửi lên Kafka Topic.
- Spark Job sẽ đọc các log mới từ Kafka topic để transform mỗi cách thích hợp, sau đó lưu vào HDFS với định dạng PARQUET.
- Hive sẽ sử dụng external table để truy vấn trên dữ liệu chỉ định

## Cấu trúc thư mục
Tự build image cho từng component, lưu trữ trên registry (Docker Hub, Harbor, hoặc private registry)

Cấu hình Kubernetes manifests: Deployment/StatefulSet, Service, ConfigMap, Secret, PersistentVolumeClaim

```txt
app-log-process-k8s/
│
├── docker-images/              # Dockerfile và source code custom image
│   ├── hadoop/                 # Custom Hadoop image (NameNode, DataNode, YARN...)
│   │   ├── Dockerfile
│   │   ├── config/             # config Hadoop xml files (core-site.xml, hdfs-site.xml...)
│   │   └── scripts/            # entrypoint scripts khởi tạo cluster
│   │
│   ├── spark/                  # Custom Spark image (Driver, Executor)
│   │   ├── Dockerfile
│   │   ├── jars/               # Dependencies JAR library để chạy các dịch vụ kết nối với kafka
│   │   └── scripts/            # Script Python hoặc Java để chạy Job
│   │
│   ├── kafka/                  # Kafka broker image, config of kafka will be in YAML file in k8s
│   │   ├── Dockerfile          
│   │   └── scripts/            # Run kafka
│   │
│   ├── hive/                   # Hive Metastore + CLI
│   │   ├── Dockerfile
│   │   ├── config/             # hive-site.xml
│   │   └── scripts/
│   │
│   └── application/            # App giả lập sinh log
│       ├── Dockerfile          
        ├── config/             # Các tham số để sinh log
        ├── app/                # Script Python để giả lập log
│       └── scripts/
│
├── k8s/                        # Kubernetes manifests
│   ├── hadoop/
│   │
│   ├── spark/
│   │
│   ├── kafka/
|   |
│   ├── hive/
│   │
│   ├── dbt/
│
├── docs/                       # Tài liệu hướng dẫn, kiến trúc
│
└── README.md
```

## Yêu cầu hệ thống
### Môi trường phát triển
- **OS**: Windows 10/11, macOS, hoặc Linux
- **Python**: 3.11+
- **Docker**: 4.41.2+
- **Kubernetes**: v1.30.5+
- **Helm**: 3.12.0+
- **kubectl**: v1.30.5+
### Phiên bản các thành phần
- **Hadoop**: 3.3.6
- **Kafka**: 3.6.0
- **Spark**: 3.5.5
- **Hive**: 3.1.3
- **PostgreSQL**: 13 (Hive Metastore)
- **ZooKeeper**: 3.9

## Hướng dẫn triển khai
### 1. Build docker images
Trước hết, bạn cần build các image để chạy hadoop, kafka, spark, hive và simulation application.
```bash
# Build Hadoop image
docker build -t custom-hadoop:latest docker-images/hadoop

# Build Kafka image
docker build -t custom-kafka:latest docker-images/kafka

# Build Spark image
docker build -t custom-spark:latest docker-images/spark

# Build Hive image
docker build -t custom-hive:latest docker-images/hive

# Build simulation application image
docker build -t sim-app:latest docker-images/application
```
> **Lưu ý**: Quá trình build có thể mất 10-30 phút cho lần đầu tiên.

Phần lớn các image đều được build từ bitnami để gọn nhẹ hơn, bạn có thể tự lựa chọn phiên bản phù hợp nhưng cần đảm bảo chúng tương thích với nhau.

Với spark, bạn cũng cần thêm các file JAR cần thiết tương thích với phiên bản bạn chọn. Các file JAR đều có thể được tìm thấy trên Maven Repo hoặc lấy ngay trong repo này, ở [spark_dependencies](docker_images/spark/jars)
### 2. Tạo namespace trên k8s
Để dễ quản lý hệ thống, nên tạo một namespace riêng trên k8s. Trong project này chúng tôi sử dụng namespace mặc định là `applog`.
```bash
kubectl create namespace applog
```
Nếu bạn muốn thay đổi namespace, cần thay đổi cả các file YAML (trong `metadata.namespace` ở mỗi file).

### 3. Triển khai Hadoop Cluster lên K8s
#### 3.1. Tạo config map
Để triển khai Hadoop lên K8s, trước hết, bạn cần tạo config map chứa các file config của hadoop ở `docker-images/hadoop/config`.
```bash
kubectl create configmap hadoop-config --from-file=docker-images/hadoop/config -n applog
```
#### 3.2. Triển khai namenode
```bash
kubectl apply -f k8s/hadoop/namenode.yaml -n applog
```

Đợi NameNode khởi động hoàn tất:

```bash
kubectl wait --for=condition=ready pod -l app=hadoop,role=namenode -n applog --timeout=300s
```
#### 3.3. Triển khai datanode
Triển khai datanode
```bash
kubectl apply -f k8s/hadoop/datanode.yaml -n applog
```
#### 3.4. Triển khai YARN (Option): 
Trong dự án cung cấp cả `resourcemanager` và `nodemanager` để chạy MapReduce. Tuy nhiên bạn có thể bỏ vì dự án không tập trung xử lý bằng MapReduce. Nếu dùng bạn hãy triển khai
```bash
kubectl apply -f k8s/hadoop/resourcemanager.yaml -n applog
kubectl apply -f k8s/hadoop/nodemanager.yaml -n applog
```
#### 3.5. Truy cập namenode để cấu hình
Ta truy cập namenode để chuẩn bị các thư mục và cấp quyền cần thiết

```bash
kubectl exec -it hadoop-namenode-0 -n applog -- bash
```
Sau đó có thể kiểm tra bằng 1 vài lệnh như
```bash
# Kiểm tra trạng thái HDFS
hdfs dfsadmin -report

# Tạo thư mục cho dữ liệu streaming và checkpoint
hdfs dfs -mkdir -p /applog/streaming
hdfs dfs -mkdir -p /checkpoints/logs-v2

# Tạo thư mục tạm (dùng để lưu các thông tin tạm, thường dùng cho Hive)
hdfs dfs -mkdir -p /tmp

# Cấu hình quyền truy cập bằng ACL, có các user spark và hive
hdfs dfs -setfacl -m user:spark:rwx /applog/streaming
hdfs dfs -setfacl -m user:spark:rwx /checkpoints/logs-v2
hdfs dfs -setfacl -m user:hive:rwx /tmp

# Thoát khỏi pod
exit
```
### 4. Triển khai Kafka Cluster lên K8s
#### 4.1. Triển khai ZooKeeper

```bash
kubectl apply -f k8s/kafka/zookeeper.yaml -n applog
```

#### 4.2. Triển khai Kafka Broker

```bash
kubectl apply -f k8s/kafka/broker.yaml -n applog
```

#### 4.3. Tạo Kafka Topics

Truy cập vào Kafka pod để tạo topics:

```bash
# Truy cập Kafka pod
kubectl exec -it kafka-broker-0 -n applog -- bash

# Tạo topic cho application logs
kafka-topics.sh --create \
  --bootstrap-server kafka:9092 \
  --topic app-logs \
  --partitions 1 \
  --replication-factor 1

# Kiểm tra danh sách topics
kafka-topics.sh --list --bootstrap-server kafka:9092

# Thoát khỏi pod
exit
```
#### 4.4. Test Kafka (Tùy chọn)

```bash
# Tạo test producer và consumer
kubectl apply -f k8s/kafka/producer-test.yaml -n applog
kubectl apply -f k8s/kafka/consumer-test.yaml -n applog

# Kiểm tra logs
kubectl logs kafka-producer-test -n applog
kubectl logs kafka-consumer-test -n applog

# Xóa test pods
kubectl delete -f k8s/kafka/producer-test.yaml -n applog
kubectl delete -f k8s/kafka/consumer-test.yaml -n applog
```
### 5. Triển khai Spark
#### 5.1. Cài đặt Spark Operator

```bash
# Thêm Helm repository
helm repo add --force-update spark-operator https://kubeflow.github.io/spark-operator

# Cài đặt Spark Operator
helm install spark-operator spark-operator/spark-operator \
    --namespace applog \
    --create-namespace \
    --set sparkJobNamespace=applog \
    --set webhook.enable=true

# Kiểm tra trạng thái
kubectl get pods -n spark-operator
```
Ngoài ra, nếu bạn muốn tùy chỉnh nhiều hơn (thường sẽ cần do cài đặt ban đầu bị lỗi), bạn có thể down manifest của deployment hiện tại của spark-operator để chỉnh sửa trực tiếp một vài thông số qua lệnh
```bash
kubectl get deployment spark-operator-controller -n applog -o yaml > k8s/spark/spark-operator.yaml
```
Sau khi chỉnh sửa hãy tắt spark-operator mặc định rồi deploy file của bạn lên
```bash
kubectl apply -f k8s/spark/spark-operator.yaml -n applog
```
#### 5.2. Cấu hình RBAC cho Spark Operator
Bạn cần chỉ ra và deploy các quyền Spark được thực hiện trên k8s qua `Service Account`.
```bash
kubectl apply -f k8s/spark/spark-rbac.yaml -n applog
```
#### 5.3. Tạo Service Stream Driver
```bash
kubectl apply -f k8s/spark/driver.yaml -n applog
```
#### 5.4. Triển khai Spark Application 
Cuối cùng, bạn cần triển khai script xử lý streaming
```bash
kubectl apply -f k8s/spark/spark-app.yaml -n applog
```
### 6. Triển khai Application giả lập

#### 6.1. Tạo ConfigMap cho Simulation App

```bash
kubectl create configmap sim-config \
  --from-file=docker-images/application/config \
  -n applog
```

#### 6.2. Triển khai Log Generator

```bash
kubectl apply -f k8s/application/sim-application.yaml -n applog
```
### 7. Triển khai Hive để đọc và truy vấn dữ liệu

#### 7.1. Triển khai PostgreSQL cho Metastore

```bash
kubectl apply -f k8s/hive/meta-postgre-db.yaml -n applog
```

#### 7.2. Tạo Hive ConfigMap

```bash
kubectl create configmap hive-config --from-file=hive-site.xml=docker-images/hive/config/hive-site.xml -n applog
```

#### 7.3. Triển khai Hive Metastore

```bash
kubectl apply -f k8s/hive/metastore.yaml -n applog
```

#### 7.4. Triển khai Hive Server2

```bash
kubectl apply -f k8s/hive/server2.yaml -n applog
```

#### 7.5. Tạo External Tables

Truy cập Hive Server2 để tạo external tables:

```bash
# Truy cập Hive Server2 pod
kubectl exec -it deployment/hive-server2 -n applog -- bash
```
Sau đó thực hiện kết nối tới JDBC bằng beeline
```bash
# Kết nối với beeline
beeline -u jdbc:hive2://localhost:10000
```
```sql
-- Tạo database
CREATE DATABASE IF NOT EXISTS applog_db;
USE applog_db;

-- Tạo external table cho raw logs
CREATE TABLE IF NOT EXISTS app_logs (
    event_time TIMESTAMP,
    user_id INT, 
    action STRING,
    device STRING,
    location STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/applog/streaming';

-- Kiểm tra tables
SHOW TABLES;
```
Sau đó thoát
```bash
# Thoát khỏi beeline
!quit

# Thoát pod
exit
```

## Vận hành và Monitoring

### Kiểm tra trạng thái hệ thống

```bash
# Kiểm tra tất cả pods
kubectl get pods -n applog

# Kiểm tra services
kubectl get svc -n applog

# Kiểm tra persistent volumes
kubectl get pv,pvc -n applog
```

### Truy cập Web UI

#### Port Forward cho các services:

```bash
# Hadoop NameNode UI (http://localhost:9870)
kubectl port-forward hadoop-namenode-0 9870:9870 -n applog

# YARN ResourceManager UI (http://localhost:8088)
kubectl port-forward deployment/yarn-resourcemanager 8088:8088 -n applog

# Spark UI (http://localhost:4040)
kubectl port-forward service/kafka-to-hdfs-stream-driver-svc 4040:4040 -n applog
```

### Debugging và Troubleshooting

#### Kiểm tra logs của các components:

```bash
# Hadoop NameNode logs
kubectl logs hadoop-namenode-0 -n applog

# Kafka logs
kubectl logs kafka-broker-0 -n applog

# Spark application logs
kubectl logs -l app=kafka-to-hdfs-stream -n applog

# Hive Server2 logs
kubectl logs deployment/hive-server2 -n applog
```

#### Kiểm tra connectivity giữa các services:

```bash
# Test từ một pod bất kỳ
kubectl run test-pod --image=busybox --rm -it -n applog -- sh

# Test kết nối đến Kafka
nc -zv kafka 9092

# Test kết nối đến HDFS
nc -zv namenode 9000

# Test kết nối đến Hive
nc -zv hive-server2 10000
```

### Dọn dẹp hệ thống

```bash
# Xóa tất cả resources trong namespace
kubectl delete namespace applog

# Xóa Spark Operator
helm uninstall spark-operator -n spark-operator
kubectl delete namespace spark-operator
```

## Cấu hình nâng cao

### Scaling Components

#### Scale Kafka Brokers:
```bash
kubectl scale statefulset kafka-broker --replicas=3 -n applog
```

#### Scale Spark Executors:
Chỉnh sửa `executor.instances` trong `k8s/spark/spark-app.yaml`

#### Scale DataNodes:
```bash
kubectl scale statefulset hadoop-datanode --replicas=3 -n applog
```

### Performance Tuning

#### Hadoop Configuration:
- Chỉnh sửa các file trong `docker-images/hadoop/config/`
- Tăng `dfs.replication` cho high availability
- Cấu hình `dfs.blocksize` phù hợp với workload

#### Spark Configuration:
- Tăng `driver.memory` và `executor.memory` cho workload lớn
- Cấu hình `spark.sql.adaptive.enabled=true`
- Tối ưu `spark.sql.adaptive.coalescePartitions.enabled=true`

#### Kafka Configuration:
- Tăng `num.network.threads` và `num.io.threads`
- Cấu hình `log.retention.hours` phù hợp
- Tối ưu `replica.fetch.max.bytes`

## Troubleshooting thường gặp

### 1. Pod không khởi động được
```bash
kubectl describe pod <pod-name> -n applog
kubectl logs <pod-name> -n applog
```

### 2. Persistent Volume issues
```bash
kubectl get pv,pvc -n applog
kubectl describe pvc <pvc-name> -n applog
```

### 3. Network connectivity issues
```bash
kubectl get svc -n applog
kubectl describe svc <service-name> -n applog
```

### 4. Spark Job failures
```bash
kubectl get sparkapplication -n applog
kubectl describe sparkapplication kafka-to-hdfs-stream -n applog
```
