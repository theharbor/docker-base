FROM ubuntu:14.04

MAINTAINER Nick Groenen

COPY bin/build.sh /build.sh
RUN /build.sh && rm /build.sh

COPY bin/runas.py /usr/local/sbin/runas
