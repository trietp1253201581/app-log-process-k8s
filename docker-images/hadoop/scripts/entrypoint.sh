#! /bin/bash

HOSTNAME=$(hostname)
service ssh start

if [[ $HOSTNAME == *"namenode"* ]]; then
    hdfs namenode -format -force
    hdfs namenode
    tail -f $HADOOP_HOME/logs/*namenode*.log
elif [[ $HOSTNAME == *"datanode"* ]]; then
    hdfs datanode
    tail -f $HADOOP_HOME/logs/*datanode*.log
elif [[ $HOSTNAME == *"secondarynamenode"* ]]; then
    hdfs secondarynamenode
    tail -f $HADOOP_HOME/logs/*secondarynamenode*.log
elif [[ $HOSTNAME == *"resourcemanager"* ]]; then
    yarn resourcemanager
    tail -f $HADOOP_HOME/logs/*resourcemanager*.log
elif [[ $HOSTNAME == *"nodemanager"* ]]; then
    yarn nodemanager
    tail -f $HADOOP_HOME/logs/*nodemanager*.log
else
    echo "Unknown hostname: $HOSTNAME"
    exec bash
fi