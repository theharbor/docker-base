FROM ubuntu:14.04

MAINTAINER Nick Groenen

COPY bin/build.sh /build.sh
RUN /build.sh && rm /build.sh

COPY bin/play.py /usr/sbin/play
COPY bin/runas.py /usr/sbin/runas
COPY bin/runif.sh /usr/bin/runif
COPY ansible/ /opt/ansible/
COPY conf/supervisor/ /etc/supervisor/conf.d/

EXPOSE 22
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]
