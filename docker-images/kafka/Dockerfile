FROM bitnami/kafka:3.6.0

USER root
COPY config/ /opt/kafka/config/
COPY scripts/start-kafka.sh /opt/kafka/scripts/start-kafka.sh

RUN chown -R 1001:1001 /opt/kafka/
RUN chmod +x /opt/kafka/scripts/start-kafka.sh 

USER 1001
CMD ["/opt/kafka/scripts/start-kafka.sh"]
