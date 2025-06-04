# app-log-process-k8s
 A Big Data System with Hadoop, Spark, Kafka, Hive, dbt to process large log from an application

-----
## Kiến trúc hệ thống
Hệ thống hiện tại sử lý dữ liệu Streaming, luồng dữ liệu chính là
```txt
Application ------> Kafka Topic ------> Spark Streaming ------> HDFS ------> Hive (Query, external table)
```

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

## Môi trường phát triển
- Window 10
- Python 3.13.3
- Docker 4.41.2
- Kubernetes v1.30.5 (in docker)
- Visual Studio Code

## Thử nghiệm hệ thống
### Build docker image
Trước hết, bạn cần build các image để chạy hadoop, kafka, spark, hive và simulation application.
```bash
docker build -t custom-hadoop:latest docker-images/hadoop
docker build -t custom-kafka:latest docker-images/kafka
docker build -t custom-spark:latest docker-images/spark
docker build -t custom-hive:latest docker-images/hive
docker build -t sim-app:latest docker-images/application
```
Quá trình build các image có thể diễn ra trong thời gian khá dài với lần build đầu tiên (khoảng từ 10-30 phút là vẫn có thể).

Phần lớn các image đều được build từ bitnami để gọn nhẹ hơn, bạn có thể tự lựa chọn phiên bản phù hợp nhưng cần đảm bảo chúng tương thích với nhau.

Với spark, bạn cũng cần thêm các file JAR cần thiết tương thích với phiên bản bạn chọn.

Trong repo này, chúng tôi dùng các version sau:
- Hadoop: 3.3.6
- Kafka: 3.6.0
- Spark: 3.5.5
- Hive: 3.1.3

### Tạo namespace trên k8s
Để dễ quản lý hệ thống, nên tạo một namespace riêng trên k8s. Trong project này chúng tôi sử dụng namespace mặc định là `applog`.
```bash
kubectl create namespace applog
```
Nếu bạn muốn thay đổi namespace, cần thay đổi cả các file YAML (trong `metadata.namespace` ở mỗi file).

### Triển khai Hadoop lên K8s
Để triển khai Hadoop lên K8s, trước hết, bạn cần tạo config map chứa các file config của hadoop ở `docker-images/hadoop/config`.
```bash
kubectl create configmap hadoop-config --from-file=docker-images/hadoop/config -n applog
```
Triển khai namenode
```bash
kubectl apply -f k8s/hadoop/namenode.yaml -n applog
```
Triển khai datanode
```bash
kubectl apply -f k8s/hadoop/datanode.yaml -n applog
```
Triển khai YARN (Option): Trong dự án cung cấp cả `resourcemanager` và `nodemanager` để chạy MapReduce. Tuy nhiên bạn có thể bỏ vì dự án không tập trung xử lý bằng MapReduce. Nếu dùng bạn hãy triển khai
```bash
kubectl apply -f k8s/hadoop/resourcemanager.yaml -n applog
kubectl apply -f k8s/hadoop/nodemanager.yaml -n applog
```
Ngoài ra, để test, bạn có thể truy cập vào pod `hadoop-namenode-0` (do dùng statefulset) để kiểm tra
```bash
kubectl exec -it hadoop-namenode-0 -n applog -- bash
```
Sau đó có thể kiểm tra bằng 1 vài lệnh như
```bash
hdfs dfsadmin -report
jps
```

### Triển khai Kafka lên K8s
Để triển khai Kafka, bạn cần triển khai một Zookeeper trước khi triển khai Broker.
```bash
kubectl apply -f k8s/kafka/zookeeper.yaml -n applog
```
Sau đó bạn hãy triển khai Kafka broker
```bash
kubectl apply -f k8s/kafka/broker.yaml -n applog
```
Ngoài ra, có cung cấp thêm 2 Pod producer và consumer để test. Bạn có thể dùng
```bash
kubectl apply -f k8s/kafka/producer-test.yaml -n applog
kubectl apply -f k8s/kafka/consumer-test.yaml -n applog
```
Nhưng hãy nhớ xóa chúng khi chuẩn bị chạy các module khác.
```bash
kubectl delete -f k8s/kafka/producer-test.yaml -n applog
kubectl delete -f k8s/kafka/consumer-test.yaml -n applog
```
### Triển khai Spark lên K8s
Trước hết, bạn cần cài Helmet, sau đó kiểm tra bằng
```bash
helm version
```
Sau đó tải Spark Operator trên K8s (nên dùng)
```bash
# Add the Helm repository
helm repo add --force-update spark-operator https://kubeflow.github.io/spark-operator

# Install the operator into the spark-operator namespace and wait for deployments to be ready
helm install spark-operator spark-operator/spark-operator \
    --namespace spark-operator \
    --create-namespace \
    --set sparkJobNamespace=applog \
    --set webhook.enable=true
```


