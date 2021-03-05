FROM node:12.16.3-alpine3.11 as builder

LABEL maintainer="anjia0532@gmail.com"
ARG YAPI_VERSION=master

WORKDIR /yapi
RUN apk add --no-cache wget
RUN wget https://github.com/YMFE/yapi/archive/${YAPI_VERSION}.zip -O yapi-${YAPI_VERSION}.zip
RUN unzip yapi-${YAPI_VERSION}.zip && mv yapi-${YAPI_VERSION} vendors
RUN npm install -g --registry https://registry.npm.taobao.org yapi-cli ykit
RUN cd /yapi/vendors && \
  cp config_example.json /yapi/config.json && \
  npm install --production && \
  yapi plugin --name yapi-plugin-notifier && \
  yapi plugin --name yapi-plugin-export-docx-data && \
  yapi plugin --name yapi-plugin-add-user

FROM node:12.16.3-alpine3.11

LABEL maintainer="anjia0532@gmail.com"

ENV TZ="Asia/Shanghai"
WORKDIR /yapi/vendors
COPY --from=builder /yapi/vendors /yapi/vendors
EXPOSE 3000
ENTRYPOINT ["node"]

