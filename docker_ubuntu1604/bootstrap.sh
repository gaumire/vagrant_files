apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
cp /vagrant/provision/docker.list /etc/apt/sources.list.d/.
apt-get update
apt-get install -y linux-image-extra-$(uname -r) docker-engine
usermod -aG docker ubuntu
service docker restart
