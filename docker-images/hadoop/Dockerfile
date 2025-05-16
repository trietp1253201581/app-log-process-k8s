FROM openjdk:8-jdk 

ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN apt-get update && \
    apt-get install -y wget ssh rsync && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 hadoop && \
    useradd -u 1000 -g hadoop -ms /bin/bash hadoop && \
    mkdir -p /home/hadoop/.ssh && \
    chown -R hadoop:hadoop /home/hadoop

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

RUN mkdir -p /hadoop/dfs/name /hadoop/dfs/data /hadoop/dfs/secondary && \
    chown -R hadoop:hadoop /hadoop && \
    chmod -R 755 /hadoop

RUN mkdir -p $HADOOP_HOME/logs && chown -R hadoop:hadoop $HADOOP_HOME/logs && \
    chmod -R 755 $HADOOP_HOME/logs

RUN mkdir -p /run/sshd && chmod 755 /run/sshd

COPY config/ $HADOOP_HOME/etc/hadoop/
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown hadoop:hadoop /entrypoint.sh

RUN service ssh start

USER hadoop
WORKDIR /home/hadoop

ENTRYPOINT ["/entrypoint.sh"]