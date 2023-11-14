FROM python:3.8-alpine

ARG CURATOR_VERSION=6.0.0

RUN pip install -U elasticsearch-curator==${CURATOR_VERSION} &&\
    rm -rf /var/cache/apk/*

COPY ./config/ /config

RUN /usr/bin/crontab /config/crontab.txt

CMD ["/usr/sbin/crond","-f"]
