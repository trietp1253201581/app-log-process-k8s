FROM bitnami/spark:3.5.5

USER root

COPY config /opt/spark/conf/
COPY jars /opt/spark/jars/

ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH