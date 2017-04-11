#!/bin/bash

# Add apt sources
sudo sh -c 'echo deb https://apt.dockerproject.org/repo ubuntu-xenial main > /etc/apt/sources.list.d/docker.list'
sudo sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'

sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198

# install required packages
sudo apt-get update
sudo apt-get install -y
sudo apt-get install -y apt-transport-https ca-certificates buildkite-agent linux-image-extra-$(uname -r) docker-engine docker-compose systemd

# update agent token in buildkite-agent
sudo sed -i "s/xxx/yyy/g" /etc/buildkite-agent/buildkite-agent.cfg

# copy over the systemd service descr
sudo cp /usr/share/buildkite-agent/systemd/buildkite-agent@.service /etc/systemd/system/.

# add users to docker groups
usermod -aG docker ubuntu
usermod -aG docker buildkite-agent

# restart docker
service docker restart

# Download docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# enable buildkite-agent and start them
for agent_count in {1..5}; do
  sudo systemctl enable buildkite-agent@${agent_count}
  sudo systemctl start buildkite-agent@${agent_count}
done
