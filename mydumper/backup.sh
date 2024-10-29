#!/usr/bin/env bash
set -e

RED='\033[0;31m'
NC='\033[0m' # No Color
# mydumper 和 mysqlbinlog 是必备的
if ! [ -x "$(command -v mydumper)" ]; then
  echo  -e "${RED}错误: 请先安装 mydumper 工具 参考 https://mydumper.github.io/mydumper/docs/html/installing.html#yum .${NC}" >&2
  exit 1
fi

if ! [ -x "$(command -v mysqlbinlog)" ]; then
  echo  -e "${RED}错误: 请先安装 mysqlbinlog 工具 , sudo yum install mysql .${NC}" >&2
  exit 1
fi

usage () { echo "用法 : $0 -h <mysql host,默认localhost> -P <mysql port,默认3306> -u <mysql user> -p <mysql password> -d <mysql database,选填,默认全部> -t <threads,默认4> -m <备份方法,total全备,db单库备,inc增量备,默认total>"; }

host=localhost
port=3306
threads=4
method=total
# 解析入参
while getopts "h:P:u:p:d:t:m:" opts; do
   case ${opts} in
      h) host=${OPTARG} ;;
      P) port=${OPTARG} ;;
      u) user=${OPTARG} ;;
      p) password=${OPTARG} ;;
      d) dbs=${OPTARG} ;;
      t) threads=${OPTARG} ;;
      m) method=${OPTARG} ;;
      *) usage; exit;;
   esac
done

echo -e "host:${host} port:${port} user:${user} password: ****** dbs:${dbs} threads:${threads} method:${method}\n"

ctime=`date +'%Y%m%d'`
cday=`date +%u`
info_file=bak_info
log_file=bak.log
pbz2_cmd="pbzip2 -m800 -5 -b8000 -l"
bak_dir=/tmp/backup


# 检查入参
if [ ! "$host" ] || [ ! "$port" ] || [ ! "$user" ] || [ ! "$password" ]
then
    usage
    exit 1
fi

aliyun_access_key=${ALIYUN_ACCESS_KEY}
aliyun_secret_key=${ALIYUN_SECRET_KEY}
aliyun_bucket=${ALIYUN_BUCKET}
aliyun_endpoint=${ALIYUN_ENDPOINT}

# 如果配置了阿里云oss，则使用s3fs挂载oss
if [ ! -z "$aliyun_access_key" ] && [ ! -z "$aliyun_secret_key" ] && [ ! -z "$aliyun_bucket" ] && [ ! -z "$aliyun_endpoint" ]
then
  mkdir -p ${bak_dir}
  echo ${aliyun_access_key}:${aliyun_secret_key} > ${HOME}/.passwd-s3fs
  chmod 600 ${HOME}/.passwd-s3fs
  s3fs ${aliyun_bucket} ${bak_dir} -o passwd_file=$HOME/.passwd-s3fs -ourl=${aliyun_endpoint}
fi

total_backup(){
  total_dir=${bak_dir}/total_data_${ctime}
  mkdir -p ${total_dir}
  mydumper --host ${host} --port ${port} --user ${user} --password ${password} --less-locking --logfile ${total_dir}/${log_file} --threads ${threads} --outputdir ${total_dir} && \
  echo "latest_dir=${total_dir}" > ${total_dir}/$info_file

  pos=`awk '/^Position/{print $3}' ${total_dir}/metadata`
  binlog=`awk '/^File/{print $3}' ${total_dir}/metadata`
  echo -e "end_pos=${pos}\nend_binlog=${binlog}" >> ${total_dir}/${info_file}
#   tar cf - $total_dir |$pbz2_cmd > ${total_dir}.tbz2
}

db_backup(){
  total_dir=${bak_dir}/total_data_${ctime}
  for db in $dbs ;do
    mkdir -p ${total_dir}/${db}
    mydumper --host ${host} --port ${port} --user ${user} --password ${password} --less-locking --logfile ${total_dir}/${log_file} --threads ${threads} --outputdir ${total_dir}/${db} --database ${db} && \
    echo "latest_dir=${total_dir}/${db}" > ${total_dir}/${db}/${info_file}

    pos=`awk '/^Position/{print $3}' ${total_dir}/${db}/metadata`
    binlog=`awk '/^File/{print $3}' ${total_dir}/${db}/metadata`
    echo -e "end_pos=${pos}\nend_binlog=${binlog}" >> ${total_dir}/${db}/${info_file}
#     tar cf - ${db}_$total_dir |$pbz2_cmd > ${db}_${total_dir}.tbz2
  done
}

inc_backup(){
    total_dir=${bak_dir}/total_data_${ctime}
    if [ ! "$dbs" ]; then
      . ${total_dir}/$info_file
      start_pos=${end_pos}
      start_binlog=${end_binlog}
      end_pos=`mysql -h$host -P$port -u$user -p$password -e 'show master status' 2> /dev/null |awk  'NR==2{print $2}'`
      end_binlog=`mysql -h$host -P$port -u$user -p$password -e 'show master status' 2> /dev/null |awk  'NR==2{print $1}'`
      increment_file=${total_dir}/increment_${ctime}

      if [ ${end_binlog} \> ${start_binlog} ] ;then
        mysqlbinlog --host=${host} --port=${port} --user=${user} --password=${password} --start-position ${start_pos} --read-from-remote-server ${start_binlog} > ${increment_file}
        mysqlbinlog --host=${host} --port=${port} --user=${user} --password=${password} --stop-position ${end_pos} --read-from-remote-server ${end_binlog} >> ${increment_file}
      elif [ $end_binlog \= $start_binlog ] ;then
        mysqlbinlog --host=${host} --port=${port} --user=${user} --password=${password} --start-position ${start_pos} --stop-position ${end_pos} --read-from-remote-server ${start_binlog} > ${increment_file}
      fi
  #     rm -rf ./$latest_dir
      echo -e "latest_dir=${increment_file}\nend_pos=${end_pos}\nend_binlog=${end_binlog}" > ${total_dir}/${info_file}
  #     tar cf - $increment_file |$pbz2_cmd > ${increment_file}.tbz2
    else
        for db in $dbs ;do
          . ${total_dir}/${db}/$info_file
          start_pos=${end_pos}
          start_binlog=${end_binlog}
          end_pos=`mysql -h$host -P$port -u$user -p$password -e 'show master status' 2> /dev/null |awk  'NR==2{print $2}'`
          end_binlog=`mysql -h$host -P$port -u$user -p$password -e 'show master status' 2> /dev/null |awk  'NR==2{print $1}'`
          increment_file=${total_dir}/increment_${ctime}

          if [ ${end_binlog} \> ${start_binlog} ] ;then
            mysqlbinlog --host=${host} --port=${port} --user=${user} --password=${password} --database ${db} --start-position ${start_pos} --read-from-remote-server ${start_binlog} > ${increment_file}
            mysqlbinlog --host=${host} --port=${port} --user=${user} --password=${password} --database ${db} --stop-position ${end_pos} --read-from-remote-server ${end_binlog} >> ${increment_file}
          elif [ $end_binlog \= $start_binlog ] ;then
            mysqlbinlog --host=${host} --port=${port} --user=${user} --password=${password} --database ${db} --start-position ${start_pos} --stop-position ${end_pos} --read-from-remote-server ${start_binlog} > ${increment_file}
          fi
      #     rm -rf ./$latest_dir
          echo -e "latest_dir=${increment_file}\nend_pos=${end_pos}\nend_binlog=${end_binlog}" > ${total_dir}/${db}/${info_file}
      #     tar cf - $increment_file |$pbz2_cmd > ${increment_file}.tbz2
        done
    fi
}

# 恢复： myloader  --host ${host} --port ${port} --user ${user} --password ${password} -t ${threads} --append-if-not-exist -o --innodb-optimize-keys -B hj -d 备份目录

case ${method} in
  total) total_backup ;;
  db) db_backup ;;
  inc) inc_backup ;;
  *) usage; exit;;
esac
