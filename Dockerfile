FROM python:3.12-alpine

WORKDIR /mqttbroker

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY mqttbroker .

CMD [ "python", "./mqttbroker" ]
