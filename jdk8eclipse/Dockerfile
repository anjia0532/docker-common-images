ARG BASE_IMAGE=8u472-b08-jdk-jammy
FROM eclipse-temurin:$BASE_IMAGE

ARG ARTHAS_VERSION="3.5.5"
ARG MIRROR=true
ENV TZ=Asia/Shanghai

ENV MAVEN_HOST=http://repo1.maven.org/maven2 \
    ALPINE_HOST=dl-cdn.alpinelinux.org \
    MIRROR_MAVEN_HOST=http://maven.aliyun.com/repository/public \
    MIRROR_ALPINE_HOST=mirrors.aliyun.com

# if use mirror change to aliyun mirror site
RUN if $MIRROR; then MAVEN_HOST=${MIRROR_MAVEN_HOST} ;ALPINE_HOST=${MIRROR_ALPINE_HOST} ; sed -i 's@//.*archive.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list; sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list ; fi && \
    # Update package lists and install required packages including font packages
    apt update && apt install -y --no-install-recommends vim unzip wget curl telnet iputils-ping fonts-dejavu-core && \
    # download & install arthas
    wget -qO /tmp/arthas.zip "${MAVEN_HOST}/com/taobao/arthas/arthas-packaging/${ARTHAS_VERSION}/arthas-packaging-${ARTHAS_VERSION}-bin.zip" && \
    mkdir -p /opt/arthas && \
    unzip /tmp/arthas.zip -d /opt/arthas && \
    rm /tmp/arthas.zip && \
    # Clean up package cache to reduce image size
    apt autoremove -y unzip wget && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY fonts/* /usr/share/fonts/truetype/dejavu/

