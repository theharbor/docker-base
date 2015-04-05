FROM zoni/ubuntu:latest
MAINTAINER Nick Groenen

COPY bin/build.sh /build.sh
RUN /build.sh && rm /build.sh
COPY bin/servicewrapper.sh /usr/local/sbin/servicewrapper

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]
