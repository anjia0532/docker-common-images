FROM alpine

LABEL maintainer="anjia0532@gmail.com"
ARG VERSION=v-20250709

ENV TZ="Asia/Shanghai"
WORKDIR /app

ADD https://github.com/yu-xiaoyao/jrebel-license-active-server/releases/download/${VERSION}/jrebel-license-active-server-linux_amd64 /app/jrebel-license-active-server
RUN chmod +x /app/jrebel-license-active-server

EXPOSE 12345
CMD ["/app/jrebel-license-active-server"]

