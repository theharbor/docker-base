FROM ubuntu:14.04

MAINTAINER Nick Groenen

COPY bin/build.sh /build.sh
RUN /build.sh && rm /build.sh

COPY bin/play.py /usr/local/sbin/play
COPY bin/runas.py /usr/local/sbin/runas
COPY bin/runif.sh /usr/local/bin/runif
COPY bin/servicewrapper.sh /usr/local/sbin/servicewrapper
COPY ansible/ /opt/ansible/
COPY conf/supervisor/ /etc/supervisor/conf.d/

EXPOSE 22
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]
