FROM ubuntu:14.04

MAINTAINER Jan Guth <jan.guth@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV NOTVISIBLE "in users profile"

RUN \
  apt-get update && \
  apt-get install -y \
    curl \
    openssh-server \
	&& rm -rf /var/lib/apt/lists/* \
  && apt-get autoremove

RUN \
  curl -s https://get.docker.io/ubuntu/ | sh && \
  echo 'DOCKER_OPTS="-H :2375 -H unix:///var/run/docker.sock"' >> /etc/default/docker

RUN \
  mkdir -p /var/run/sshd && \
  echo 'root:screencast' | chpasswd && \
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
  echo "export VISIBLE=now" >> /etc/profile

VOLUME /var/lib/docker

EXPOSE 2375
EXPOSE 22

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
