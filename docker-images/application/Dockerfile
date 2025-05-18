FROM python:3.11-slim 

WORKDIR /app 
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /etc/sim-config && chmod -R 755 /etc/sim-config 

COPY app/ app/

CMD ["python", "app/sim_log.py"]
