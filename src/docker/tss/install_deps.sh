#!/bin/bash

apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin python3 curl gcc python3-dev

rm -rf /var/lib/apt/lists/*

curl -sSL https://install.python-poetry.org | python3 -

curl -L -o g.tar.gz https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_linux_x86_64.tar.gz

tar xf g.tar.gz

mv grpcurl /root/.local/bin

rm g.tar.gz
