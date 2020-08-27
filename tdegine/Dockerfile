FROM ubuntu:focal

LABEL maintainer="anjia0532@gmail.com"

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV MIRROR_UBUNTU_HOST=mirrors.aliyun.com
ENV DEBIAN_FRONTEND=noninteractive

ARG TD_ENGINE_VERSION="ver-2.0.2.1"
ARG MIRROR=false
ARG TZ=Asia/Shanghai

# if use mirror change to aliyun mirror site
RUN if $MIRROR; then UBUNTU_HOST=${MIRROR_UBUNTU_HOST} ; sed -i "s/archive.ubuntu.com/${UBUNTU_HOST}/g" /etc/apt/sources.list ; fi && \
    apt update &&\
    # install cmake build-essential
    apt-get install -y cmake build-essential wget unzip && \
    # download & compile & install tdegine
    wget -nv --show-progress --progress=bar:force:noscroll -O /tmp/TDengine.zip  "https://github.com/taosdata/TDengine/archive/${TD_ENGINE_VERSION}.zip" && \
    unzip /tmp/TDengine.zip -d /tmp/ && \
    mv /tmp/TDengine-${TD_ENGINE_VERSION} /tmp/TDengine && \
    mkdir -p /tmp/TDengine/debug && cd /tmp/TDengine/debug && \
    cmake .. && cmake --build . && \
    mkdir -p /tmp/TDengine/packaging/deb/init.d && \
    cp /tmp/TDengine/packaging/deb/taosd /tmp/TDengine/packaging/deb/init.d/taosd && \
    make install && \
    ## cleanup compile env
    apt-get --purge remove -y cmake build-essential wget unzip && \
    apt-get clean autoclean && apt-get autoremove --purge -y && \
    rm -rf /tmp/*  && \
    rm -rf /var/cache/*  && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/  && \
    # change timezone
    apt install tzdata -y && \
    ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    dpkg-reconfigure tzdata

EXPOSE 6030 6031 6032

VOLUME ["/var/lib/taos","/var/log/taos","/etc/taos/"]
CMD ["taosd"]
