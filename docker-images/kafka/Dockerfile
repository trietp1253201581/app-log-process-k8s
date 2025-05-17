FROM bitnami/kafka:3.6.0

USER root

COPY scripts/start-kafka.sh /opt/kafka/scripts/start-kafka.sh

RUN chown -R 1001:1001 /opt/bitnami/kafka/ /opt/kafka/
RUN chmod +x /opt/kafka/scripts/start-kafka.sh 

USER 1001
CMD ["/opt/kafka/scripts/start-kafka.sh"]
