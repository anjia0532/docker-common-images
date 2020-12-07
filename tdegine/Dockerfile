FROM ubuntu:focal AS builder

LABEL maintainer="anjia0532@gmail.com"

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV MIRROR_UBUNTU_HOST=mirrors.aliyun.com
ENV DEBIAN_FRONTEND=noninteractive

ARG TD_ENGINE_VERSION="2.0.9.0"
ARG MIRROR=false
ARG TZ=Asia/Shanghai
ENV TD_FILE_NAME="ver-${TD_ENGINE_VERSION}"

# if use mirror change to aliyun mirror site
RUN if $MIRROR; then UBUNTU_HOST=${MIRROR_UBUNTU_HOST} ; sed -i "s/archive.ubuntu.com/${UBUNTU_HOST}/g" /etc/apt/sources.list ; fi && \
    apt update &&\
    # install cmake build-essential
    apt-get install -y cmake build-essential wget unzip git && \
    # download & compile & install tdegine
    git config --global advice.detachedHead false && \
    git clone -b ${TD_FILE_NAME} --depth 1 --single-branch https://github.com/taosdata/TDengine.git /tmp/enterprise && \
    sed -i -e '/makerpm/d;/makedeb/d;/jdbcdriver/d;' /tmp/enterprise/packaging/release.sh && \
    cd /tmp/enterprise/ && \
    /tmp/enterprise/packaging/release.sh -l lite -n ${TD_ENGINE_VERSION} && \
    mkdir -p /opt/taos && \
    tar zxf /tmp/enterprise/release/TDengine-server-${TD_ENGINE_VERSION}-Linux-x64-Lite.tar.gz -C /opt/taos

FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
WORKDIR /root/
COPY --from=builder /opt/taos .
# COPY --from=builder /etc/apt/sources.list /etc/apt/sources.list

RUN cd /root/"$(ls /root/ | grep TDengine-server | head -1)" && \
    ./install.sh -v server -e no && \
    ## change timezone
    # apt update &&\
    # apt install tzdata -y && \
    # ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    # echo ${TZ} > /etc/timezone && \
    # dpkg-reconfigure tzdata && \
    apt-get clean autoclean && apt-get autoremove --purge -y && \
    ## cleanup compile env
    cd /tmp && \
    rm -rf /tmp/*  && \
    rm -rf /var/cache/*  && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/  && \
    rm -rf /root/TDengine-server/ 

EXPOSE 6030 6031 6032 6033 6034 6035 6036 6037 6038 6039 6040 6041 6042

VOLUME ["/var/lib/taos","/var/log/taos","/etc/taos/"]
CMD ["taosd"]
