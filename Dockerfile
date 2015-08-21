# vim:set et ts=2 sw=2 syntax=dockerfile:

FROM       docker.xlands-inc.com/baoyu/debian
MAINTAINER djluo <dj.luo@baoyugame.com>

ADD ./conf/         /etc/
ADD ./conf/         /rsyncd/conf/
ADD ./entrypoint.pl /entrypoint.pl

ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/usr/bin/rsync", "--daemon", "--no-detach", "--config=/rsyncd/conf/rsyncd.conf"]
