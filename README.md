# app-log-process-k8s
 A Big Data System with Hadoop, Spark, Kafka, Hive, dbt to process large log from an application

-----
## Kiến trúc hệ thống
```txt
+---------------------+
|     Client/Apps      |
+---------------------+
           |
           v
+---------------------+
|  API Gateway / Proxy |
+---------------------+
           |
           v
+-----------------------------+
|  Kubernetes Cluster          |
|                             |
| +--------+  +-----------+   |
| | Kafka  |  |  Hadoop   |   |
| | (ZK)   |  |  (HDFS, YARN) |
| +--------+  +-----------+   |
|     |           |           |
| +-------+    +-------+      |
| | Spark |    |  Hive |       |
| +-------+    +-------+      |
|                             |
| +-------------+             |
| |    dbt      |             |
| +-------------+             |
+-----------------------------+
           |
           v
+-----------------------------+
| External Storage (S3, PVC...)|
+-----------------------------+

```
- `Kafka`: Messaging platform, lưu trữ và truyền streaming data

- `Hadoop HDFS + YARN`: Storage & resource manager cho batch data, MapReduce, storage

- `Spark`: Processing engine cho batch và streaming, chạy trên K8s (Spark Operator)

- `Hive`: Data warehouse, dùng để query dữ liệu trên HDFS hoặc external storage

- `dbt`: Dùng để transform dữ liệu, tạo pipeline analytics, chạy trên container, orchestration bằng K8s Job hoặc Airflow

- `Storage bên ngoài`: PVC Persistent Volumes

## Cấu trúc thư mục
Tự build image cho từng component, lưu trữ trên registry (Docker Hub, Harbor, hoặc private registry)

Cấu hình Kubernetes manifests: Deployment/StatefulSet, Service, ConfigMap, Secret, PersistentVolumeClaim

```txt
app-log-process-k8s/
│
├── docker-images/                     # Dockerfile và source code custom image
│   ├── hadoop/                 # Custom Hadoop image (NameNode, DataNode, YARN...)
│   │   ├── Dockerfile
│   │   ├── config/             # config Hadoop xml files (core-site.xml, hdfs-site.xml...)
│   │   └── scripts/            # entrypoint scripts khởi tạo cluster
│   │
│   ├── spark/                  # Custom Spark image (Driver, Executor)
│   │   ├── Dockerfile
│   │   ├── config/             # spark-defaults.conf, spark-env.sh
│   │   └── scripts/
│   │
│   ├── kafka/                  # Kafka + Zookeeper custom image
│   │   ├── Dockerfile
│   │   ├── config/             # server.properties, zookeeper.properties
│   │   └── scripts/
│   │
│   ├── hive/                   # Hive Metastore + CLI
│   │   ├── Dockerfile
│   │   ├── config/             # hive-site.xml, metastore-site.xml
│   │   └── scripts/
│   │
│   └── dbt/                    # dbt container
│       ├── Dockerfile
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
- Python 3.13
- Docker 4.41.2
- Kubernetes v1.30.5 (in docker)
- Visual Studio Code

## Thử nghiệm hệ thống
### Build docker image

