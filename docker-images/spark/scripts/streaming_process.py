from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, from_unixtime
from pyspark.sql.types import StructType, StringType, TimestampType, DoubleType

spark = SparkSession.Builder().appName("Kafka2HDFS")\
    .config('spark.sql.parquet.outputTimestampType', 'INT96').getOrCreate()

schema = StructType() \
    .add("event_time", DoubleType()) \
    .add("user_id", StringType()) \
    .add("action", StringType()) \
    .add("device", StringType()) \
    .add("location", StringType())

df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "app-logs") \
    .option("startingOffsets", "latest") \
    .option("failOnDataLoss", "false") \
    .load()
    
json_df = df.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.*") \
    .withColumn("event_time", from_unixtime(col("event_time")).cast("timestamp"))
    
def write_to_parquet(batch_df, batch_id):
    batch_df.write \
        .mode("append") \
        .option("timestampFormat", "yyyy-MM-dd HH:mm:ss") \
        .parquet("hdfs://namenode:9000/applog/streaming")

query = json_df.writeStream \
    .foreachBatch(write_to_parquet)\
    .option("checkpointLocation", "hdfs://namenode:9000/checkpoints/logs-v2") \
    .start()
    
query.awaitTermination()