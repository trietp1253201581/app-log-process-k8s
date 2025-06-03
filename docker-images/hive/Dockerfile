FROM apache/hive:3.1.3

USER root

# Cài đặt các gói cần thiết (nếu cần)
RUN apt-get update && apt-get install -y procps netcat \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/hive/.beeline && chown -R hive:hive /home/hive 

COPY config/hive-site.xml /opt/hive/conf/
COPY scripts/entrypoint.sh /entrypoint.sh

RUN chown -R hive:hive /opt/hive /entrypoint.sh \
    && chmod +x /entrypoint.sh

RUN mkdir -p /check && chown -R hive:hive /check && chmod -R 755 /check

USER hive

ENTRYPOINT ["/entrypoint.sh"]
