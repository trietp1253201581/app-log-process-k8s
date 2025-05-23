from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StringType, TimestampType

spark = SparkSession.Builder().appName("Kafka2HDFS").getOrCreate()

schema = StructType() \
    .add("timestamp", TimestampType()) \
    .add("user_id", StringType()) \
    .add("action", StringType()) \
    .add("device", StringType()) \
    .add("location", StringType())

df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "logs") \
    .option("startingOffsets", "earliest") \
    .load()
    
json_df = df.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.*")

query = json_df.writeStream \
    .format("parquet") \
    .option("path", "hdfs://namenode:9000/output/logs") \
    .option("checkpointLocation", "hdfs://namenode:9000/checkpoints/logs") \
    .outputMode("append") \
    .start()
    
query.awaitTermination()