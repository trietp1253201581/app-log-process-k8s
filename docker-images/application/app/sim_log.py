import time 
import json
import yaml
import random

from faker import Faker
from kafka import KafkaProducer

# Load config
CONFIG_PATH = '/etc/sim-config/generator-config.yaml'
with open(CONFIG_PATH) as f:
    config = yaml.safe_load(f)
    
faker = Faker()

producer = KafkaProducer(
    bootstrap_servers = config['kafka']['bootstrap-servers'],
    value_serializer = lambda x: json.dumps(x).encode('utf8') 
)

def simulate_log():
    return {
        "timestamp": time.time(),
        "user_id": faker.uuid4(),
        "action": random.choice(['click', 'view', 'purcharse', 'login', 'logout']),
        "device": faker.user_agent(),
        "location": faker.city()
    }
    
log_rate = config['generator']['log-rate']
interval = 1.0 / log_rate
kafka_topic = config['kafka']['topic']

while True:
    log = simulate_log()
    try:
        producer.send(kafka_topic, value=log)
    except:
        print("Error when send to kafka topic")
    time.sleep(interval)

