# vim:set et ts=2 sw=2 syntax=dockerfile:

FROM       docker.xlands-inc.com/baoyu/debian
MAINTAINER djluo <dj.luo@baoyugame.com>

ADD ./rsyncd.conf   /etc/
ADD ./entrypoint.pl /entrypoint.pl

ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/usr/bin/rsync", "--daemon", "--no-detach" ]
