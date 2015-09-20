#!/bin/bash

if [ ! -z "${AUTHORIZED_KEYS}" ]; then
  if [[ "${AUTHORIZED_KEYS}" =~ '(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]' ]]; then
    curl -Ls "${AUTHORIZED_KEYS}" | sudo tee -a /home/cattle/.ssh/authorized_keys
  else
    echo "${AUTHORIZED_KEYS}" | sudo tee -a /home/cattle/.ssh/authorized_keys
  fi
fi

# make sure docker group is set on socket
sudo chgrp docker /var/run/docker.sock
sudo restart docker
sudo service ssh start

if [ -z $1 ]; then
  set -- bash "$@"
#  set -- /usr/sbin/sshd -D "$@"
#else
fi

exec "$@"
