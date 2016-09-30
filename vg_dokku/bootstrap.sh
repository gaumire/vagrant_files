apt-get update
apt-get install -y linux-image-extra-$(uname -r)
wget https://raw.githubusercontent.com/dokku/dokku/$DOKKU_TAG/bootstrap.sh
bash bootstrap.sh