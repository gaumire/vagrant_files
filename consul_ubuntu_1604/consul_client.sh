#!/bin/bash
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
cp /vagrant/provision/docker.list /etc/apt/sources.list.d/.
apt-get update
apt-get install -y apt-transport-https ca-certificates linux-image-extra-$(uname -r) docker-engine unzip
usermod -aG docker ubuntu
service docker restart
wget https://releases.hashicorp.com/consul/0.8.3/consul_0.8.3_linux_amd64.zip -O /tmp/consul.zip
unzip /tmp/consul.zip -d /usr/local/bin/
useradd -m consul -d /var/consul
mkdir -p /etc/consul.d
chown consul:consul /etc/consul.d

IP_ADDR=$(ip addr show enp0s8 | grep 'inet ' | awk '{print $2}' | cut -d/ -f 1)

cat > /etc/consul.d/config.json <<EOF
{
"bind_addr": "$IP_ADDR",
"client_addr": "0.0.0.0",
"datacenter": "dc1",
"data_dir": "/var/consul",
"log_level": "INFO",
"enable_syslog": true,
"enable_debug": true,
"node_name": "$HOSTNAME",
"server": false,
"ports" : {
  "dns" : 53
},
"ui": true,
"retry_join": [
  "192.168.135.10",
  "192.168.135.11",
  "192.168.135.12"
  ]
}
EOF

cat > /etc/consul.d/disk.json <<EOF
{
  "check": {
     "name": "Disk Util",
     "script": "disk_util=$(df -k | grep '/dev/sda1' | awk '{print $5}' | sed 's/[^0-9]*//g' ) | if [ $disk_util >  90 ] ; then echo 'Disk /dev/sda above 90% full' && exit 1; elif [ $disk_util > 80 ] ; then echo 'Disk /dev/sda above 80%' && exit 3;  else echo 'All OK'; exit 0; fi",
     "interval": "30s"
     }
}
EOF

cat > /etc/systemd/system/consul.service <<EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir /etc/consul.d/
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.targetEOF
EOF

service consul start

sleep 2
docker run -d -v /var/run/docker.sock:/tmp/docker.sock --name registrator -h $HOSTNAME gliderlabs/registrator:latest -ip $IP_ADDR consul://$IP_ADDR:8500

sleep 2
docker run -d -e SERVICE_CHECK_HTTP=/ -e SERVICE_CHECK_INTERVAL=5s -e SERVICE_CHECK_TIMEOUT=3s --name service1 -P yadavsms/python-micro-service
