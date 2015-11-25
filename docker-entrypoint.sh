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
sudo service ssh stop

sudo chown cattle:cattle -R /data

if [ ! -z "${DOCKER_LOGIN_HOST}" ]; then
  sudo docker login -u "${DOCKER_LOGIN_USER}" --password="${DOCKER_LOGIN_PASS}" -e "${DOCKER_LOGIN_EMAIL}" "${DOCKER_LOGIN_HOST}"
fi

IFS=' ' read -ra IMAGE <<< "${DOCKER_PULL}"
for i in "${IMAGE[@]}"; do
  sudo docker pull "${i}" &
done

if [ -z "${1}" ] || [ "${1:0:1}" = '-' ]; then
#  set -- bash "$@"
  set -- /usr/sbin/sshd -D "$@"
#else
fi

exec "$@"
