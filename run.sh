#!/bin/bash
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 4.0(20150107)

# chkconfig: 3 90 19
# description:
# processname: redmine container

[ -r "/etc/baoyu/functions"  ] && source "/etc/baoyu/functions" && _current_dir
[ -f "${current_dir}/docker" ] && source "${current_dir}/docker"

# ex: ...../dir1/dir2/run.sh
# container_name is "dir1-dir2"
_container_name ${current_dir}

images="${registry}/baoyu/rsyncd"
default_port="2873:2873"

action="$1"    # start or stop ...
_get_uid "$2"  # uid=xxxx ,default is "1000"
shift $flag_shift
unset  flag_shift

# 转换需映射的端口号
app_port="$@"  # hostPort
app_port=${app_port:=${default_port}}
_port


_run() {
  local mode="-d" # --restart=always"
  local name="$container_name"
  local cmd=""

  [ "x$1" == "xdebug" ] && _run_debug

  sudo docker run $mode $port \
    --add-host=machine:172.17.42.1 \
    -e "TZ=Asia/Shanghai"     \
    -e "User_Id=${User_Id}"   \
    -w "/rsyncd/"             \
    -e "RSYNC_PASSWORD=docker" \
    -e "backup_dest=$name"     \
    -e "backup_ip=172.17.42.1" \
    -v ${current_dir}/logs/:/rsyncd/logs/ \
    -v ${current_dir}/conf/:/rsyncd/conf/ \
    -v ${current_dir}/data/:/rsyncd/data/ \
    --name ${name} ${images} \
    $cmd
}
###############
_call_action $action
