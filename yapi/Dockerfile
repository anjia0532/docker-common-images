FROM node:12-alpine as builder

LABEL maintainer="anjia0532@gmail.com"
ARG YAPI_VERSION=master

WORKDIR /yapi
RUN apk add --no-cache wget
RUN wget https://github.com/YMFE/yapi/archive/${YAPI_VERSION}.zip -O yapi-${YAPI_VERSION}.zip
RUN unzip yapi-${YAPI_VERSION}.zip && mv yapi-${YAPI_VERSION} vendors
RUN cd /yapi/vendors && \
 cp config_example.json /yapi/config.json && \
 npm install --production --registry https://registry.npm.taobao.org

FROM node:12-alpine

LABEL maintainer="anjia0532@gmail.com"

ENV TZ="Asia/Shanghai"
WORKDIR /yapi/vendors
COPY --from=builder /yapi/vendors /yapi/vendors
EXPOSE 3000
ENTRYPOINT ["node"]

