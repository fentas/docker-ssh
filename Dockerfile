FROM ubuntu:14.04
MAINTAINER Jan Guth <jan.guth@gmail.com>

ENV AUTHORIZED_KEYS ""

ENV DOCKER_PULL ""
ENV DOCKER_LOGIN_HOST ""
ENV DOCKER_LOGIN_USER ""
ENV DOCKER_LOGIN_PASS ""
ENV DOCKER_LOGIN_EMAIL ""

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r cattle && useradd -r -g cattle cattle

RUN \
  export DOCKER_ENGINE="1.8.3-0~trusty" && \
  export DOCKER_COMPOSE="1.5.1" && \
  apt-get update && \
  apt-get install -y \
    curl \
    openssh-server && \
  curl -Ls https://get.docker.com/ | sed "s/docker-engine/docker-engine=${DOCKER_ENGINE}/" | sh && \
  echo 'DOCKER_OPTS="-H :2375 -H unix:///var/run/docker.sock"' >> /etc/default/docker && \
  curl -sL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE}/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null && \
  sudo chmod +x /usr/local/bin/docker-compose && \
  usermod -aG docker cattle && \
  rm -rf /var/lib/apt/lists/* && \
  find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true && \
  find /usr/share/doc -empty|xargs rmdir || true && \
  rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/* && \
  rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*

RUN \
  mkdir -p /var/run/sshd && \
  sed 's/#?PermitRootLogin [a-z_-]+/PermitRootLogin no/' -r -i /etc/ssh/sshd_config && \
  sed 's/#?PasswordAuthentication [a-z_-]+/PasswordAuthentication no/' -r -i /etc/ssh/sshd_config && \
  sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd

COPY ./authorized_keys /home/cattle/.ssh/

RUN \
  chmod 700 /home/cattle/.ssh/ && \
  chmod 600 /home/cattle/.ssh/authorized_keys && \
  chown cattle:cattle -R /home/cattle

VOLUME /var/lib/docker
VOLUME /data
RUN chown cattle:cattle -R /data

EXPOSE 2375
EXPOSE 22

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
