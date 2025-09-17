FROM openjdk:8-jdk

ARG ARTHAS_VERSION="3.7.3"
ARG MIRROR=false
ARG TIMEZONE=""
ENV TZ=Asia/Shanghai

ENV MAVEN_HOST=https://repo1.maven.org/maven2 \
    MIRROR_MAVEN_HOST=https://maven.aliyun.com/repository/public

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# if use mirror change to aliyun mirror site
RUN if $MIRROR; then MAVEN_HOST=${MIRROR_MAVEN_HOST} ; fi && \
    wget -qO /tmp/arthas.zip "${MAVEN_HOST}/com/taobao/arthas/arthas-packaging/${ARTHAS_VERSION}/arthas-packaging-${ARTHAS_VERSION}-bin.zip" && \
    mkdir -p /opt/arthas && \
    unzip /tmp/arthas.zip -d /opt/arthas && \
    rm /tmp/arthas.zip
