FROM eclipse-temurin:8u472-b08-jre-alpine-3.22
LABEL maintainer="anjia0532 <anjia0532@gmail.com>"

ARG CANAL_VERSION="1.1.8"
ARG CANAL_TYPE="server"

ENV TZ Asia/Shanghai
ENV CANAL_HOME /app/$CANAL_TYPE

RUN set -eux; \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories; \
    apk --no-cache add tzdata curl wget net-tools bash file; \
    \
    cp /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    \
    mkdir -p $CANAL_HOME; \
    \
    if [ "$CANAL_TYPE" = "server" ]; then \
        downloadUrl="https://github.com/alibaba/canal/releases/download/canal-$CANAL_VERSION/canal.deployer-$CANAL_VERSION.tar.gz"; \
    else \
        downloadUrl="https://github.com/alibaba/canal/releases/download/canal-$CANAL_VERSION/canal.$CANAL_TYPE-$CANAL_VERSION.tar.gz"; \
    fi; \
    curl -fsSL -o canal.tgz "$downloadUrl"; \
    tar -xzvf canal.tgz --directory "$CANAL_HOME"; \
    rm canal.tgz*; \
    \
    rm -f $CANAL_HOME/bin/*.bat; \
    sed -i 's/1>>.*//' "$CANAL_HOME/bin/startup.sh"; \
    chmod +x $CANAL_HOME/bin/*.sh; \
    rm -rf $CANAL_HOME/conf/example; \
    \
    # fix bug: org.h2.jdbc.JdbcSQLDataException: Value too long for column "CHARACTER VARYING"
    curl -fsSL -o "$CANAL_HOME/lib/h2-2.2.224.jar" "https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar"; \
    rm -f $CANAL_HOME/lib/h2-2.1.210.jar; \
    \
    printf "canal=$CANAL_TYPE\n path=$CANAL_HOME"; \
    java -version

# 8081 adapter 8089 server 11110 admin , 11111 canal , 11112 metrics, 9100 exporter
EXPOSE 8081 8089 11110 11111 11112 9100

WORKDIR ${CANAL_HOME}

CMD [ "${CANAL_HOME}/bin/startup.sh" ]
