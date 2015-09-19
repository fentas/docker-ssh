FROM ubuntu:14.04
MAINTAINER Jan Guth <jan.guth@gmail.com>

ENV AUTHORIZED_KEYS ""

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r cattle && useradd -r -g cattle cattle

RUN \
  apt-get update && \
  apt-get install -y \
    curl \
    openssh-server

RUN \
  curl -Ls https://get.docker.io/ubuntu/ | sh && \
  echo 'DOCKER_OPTS="-H :2375 -H unix:///var/run/docker.sock"' >> /etc/default/docker && \
  curl -sL https://github.com/docker/compose/releases/download/1.4.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null && \
  sudo chmod +x /usr/local/bin/docker-compose && \
  usermod -aG docker cattle

RUN \
  rm -rf /var/lib/apt/lists/* && \
  apt-get autoremove

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

EXPOSE 2375
EXPOSE 22

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
