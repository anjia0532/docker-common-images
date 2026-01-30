
ARG BASE_IMAGE=8u472-b08-jdk-alpine
FROM eclipse-temurin:$BASE_IMAGE

ARG ARTHAS_VERSION="3.5.5"
ARG MIRROR=true
ENV TZ=Asia/Shanghai

ENV MAVEN_HOST=http://repo1.maven.org/maven2 \
    ALPINE_HOST=dl-cdn.alpinelinux.org \
    MIRROR_MAVEN_HOST=http://maven.aliyun.com/repository/public \
    MIRROR_ALPINE_HOST=mirrors.aliyun.com \
    LANG=en_US.UTF-8

# if use mirror change to aliyun mirror site
RUN if $MIRROR; then MAVEN_HOST=${MIRROR_MAVEN_HOST} ;ALPINE_HOST=${MIRROR_ALPINE_HOST} ; sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_HOST}/g" /etc/apk/repositories ; fi && \
    # https://github.com/docker-library/openjdk/issues/76
    apk add --no-cache tini  ttf-dejavu fontconfig && \
    # download & install arthas
    wget -qO /tmp/arthas.zip "${MAVEN_HOST}/com/taobao/arthas/arthas-packaging/${ARTHAS_VERSION}/arthas-packaging-${ARTHAS_VERSION}-bin.zip" && \
    mkdir -p /opt/arthas && \
    unzip /tmp/arthas.zip -d /opt/arthas && \
    rm /tmp/arthas.zip

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY fonts/* /usr/share/fonts/ttf-dejavu/

# Tini is now available at /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]
