#!/bin/bash
apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-get install -y unzip
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
"ports" : {
  "dns" : 53
},
"node_name": "$HOSTNAME",
"server": true,
"ui": true,
"bootstrap_expect": 3,
"retry_join": [
  "192.168.135.10:8301",
  "192.168.135.11:8301",
  "192.168.135.12:8301"
  ]
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
