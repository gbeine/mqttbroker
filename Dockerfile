FROM python:3.10-alpine

RUN apk add build-base autoconf automake libtool git python3-dev

WORKDIR /mqttbroker

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN apk del build-base autoconf automake libtool git python3-dev
RUN apk cache clean

COPY mqttbroker .

CMD [ "python", "./mqttbroker" ]
