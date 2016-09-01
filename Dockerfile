FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive 

RUN echo "deb http://apt.dockerproject.org/repo ubuntu-`lsb_release -c -s` main" > /etc/apt/sources.list.d/docker.list \
	&& apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN apt-get update && apt-get install -y \
		make \
		docker-engine \
	&& rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /
COPY Makefile /opt/docker-make-stub/Makefile
COPY *.mk /opt/docker-make-stub/

WORKDIR /opt/build
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["help"]
