#!/bin/bash

sudo service docker start
sudo service ssh start

exec "$@"
