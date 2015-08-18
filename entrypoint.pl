#!/usr/bin/perl
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 2.0(20150107)
#
# 初衷: 每个容器用不同用户运行程序,已方便在宿主中直观的查看.
# 需求: 1. 动态添加用户,不能将添加用户的动作写死到images中.
#       2. 容器内尽量不留无用进程,保持进程树干净.
# 问题: 如用shell的su命令切换,会遗留一个su本身的进程.
# 最终: 使用perl脚本进行添加和切换操作. 从环境变量User_Id获取用户信息.

use strict;
#use English '-no_match_vars';

my $uid = 1000;
my $gid = 1000;

$uid = $gid = $ENV{'User_Id'} if $ENV{'User_Id'} =~ /\d+/;

unless (getpwuid("$uid")){
  system("/usr/sbin/useradd", "-U", "-u $uid", "-m", "docker");
}

my $conf="/rsyncd/conf/rsyncd.conf";
my $pass="/rsyncd/conf/passwd";
system("cp", "/etc/rsyncd.conf", "$conf") unless ( -f $conf );
system("cp", "/etc/rsyncd.pass", "$pass") unless ( -f $pass );

if( -f $pass ){
  system("chmod", "640",    $conf, $pass);
  system("chgrp", "docker", $conf, $pass);
}

mkdir("/var/run/rsyncd") unless (-d "/var/run/rsyncd");
my @dirs = ("/var/run/rsyncd","/rsyncd/logs","/rsyncd/data");
foreach my $dir (@dirs) {
  if ( -d $dir && (stat($dir))[4] != $uid ){
    system("chown", "docker.docker", "$dir");
  }
}

my $pid="/var/run/rsyncd/pid";
unlink("$pid") if ( -f "$pid");

#system("rm", "-f", "/run/crond.pid") if ( -f "/run/crond.pid" );
#system("/usr/sbin/cron");
#
#my $min  = int(rand(60));
#my $hour = int(rand(5));
#
#my $min2 = $min;
#$min2 = $min - 3 if $min > 3;
#
#open (CRON,"|/usr/bin/crontab") or die "crontab error?";
#print CRON ("$min2 $hour * * * (/mysql/xtrab.sh delete >/mysql/backup/stdout.log 2>/mysql/backup/stderr.log)\n");
#close(CRON);

# 切换当前运行用户,先切GID.
#$GID = $EGID = $gid;
#$UID = $EUID = $uid;
$( = $) = $gid; die "switch gid error\n" if $gid != $( ;
$< = $> = $uid; die "switch uid error\n" if $uid != $< ;

$ENV{'HOME'} = "/home/docker";
exec(@ARGV);
