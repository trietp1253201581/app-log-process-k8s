#! /bin/bash

HOSTNAME=$(hostname)

if [[ $HOSTNAME == *"namenode"* ]]; then
    if [ ! -f /hadoop/dfs/name/current/VERSION ]; then
        hdfs namenode -format -force;
    fi;
    hdfs namenode
    tail -f $HADOOP_HOME/logs/*namenode*.log
elif [[ $HOSTNAME == *"datanode"* ]]; then
    hdfs datanode
    tail -f $HADOOP_HOME/logs/*datanode*.log
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