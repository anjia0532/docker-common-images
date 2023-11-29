FROM node:12.16.3-alpine3.11 as builder

LABEL maintainer="anjia0532@gmail.com"
ARG YAPI_VERSION=1.12.0

WORKDIR /yapi
RUN apk add --no-cache wget
RUN wget https://github.com/YMFE/yapi/archive/v${YAPI_VERSION}.zip -O yapi-${YAPI_VERSION}.zip
RUN unzip yapi-${YAPI_VERSION}.zip && mv yapi-${YAPI_VERSION} vendors
RUN cd /yapi/vendors && \
 cp config_example.json /yapi/config.json && \
 npm install --save node-sass@5.0.0 yapi-plugin-notifier yapi-plugin-export-docx-data yapi-plugin-add-user --registry https://registry.npm.taobao.org && \
 npm install --production --registry https://registry.npm.taobao.org

FROM node:12.16.3-alpine3.11

LABEL maintainer="anjia0532@gmail.com"

ENV TZ="Asia/Shanghai"
WORKDIR /yapi/vendors
COPY --from=builder /yapi/vendors /yapi/vendors
COPY entrypoint.sh /yapi/vendors
RUN chmod +x /yapi/vendors
EXPOSE 3000
ENTRYPOINT ["/yapi/vendors/entrypoint.sh"]

