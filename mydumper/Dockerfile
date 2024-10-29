ARG BASE_VERSION=v0.16.8-1
FROM mydumper/mydumper:$BASE_VERSION

WORKDIR /app

# https://github.com/Richienb/synergy-serial
# https://www.npmjs.com/package/synergy-serial
RUN   sed -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^# baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com|g' \
      -i.bak \
      /etc/yum.repos.d/almalinux*.repo  && \
    dnf makecache  && \
    yum install s3fs-fuse mysql -y && \
    yum clean all

COPY ./backup.sh /app/backup.sh

RUN chmod +x /app/backup.sh

CMD ["/bin/bash", "/app/backup.sh"]
