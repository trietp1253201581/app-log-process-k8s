FROM apache/hive:3.1.3

USER root

# Cài đặt các gói cần thiết (nếu cần)
RUN apt-get update && apt-get install -y procps netcat

# Copy cấu hình và entrypoint
COPY config/hive-site.xml /opt/hive/conf/
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
