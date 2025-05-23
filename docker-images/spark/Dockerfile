FROM bitnami/spark:3.5.5

USER root

COPY jars/* /opt/bitnami/spark/jars/
COPY scripts/streaming_process.py /opt/bitnami/spark/app/streaming_process.py
ENV SPARK_HOME=/opt/bitnami/spark
ENV PATH=$SPARK_HOME/bin:$PATH

USER 1001