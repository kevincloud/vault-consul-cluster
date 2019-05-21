#!/bin/sh
# Configures the Vault server for a database secrets demo

# cd /tmp
echo "Preparing to install Vault..."
sudo apt-get -y update > /dev/null 2>&1
sudo apt-get -y upgrade > /dev/null 2>&1
sudo apt install -y unzip jq cowsay mysql-client > /dev/null 2>&1

mkdir -p /etc/vault.d
mkdir -p /etc/consul.d

echo "Installing Vault..."
export CLIENT_IP=`ifconfig eth0 | grep "inet " | awk -F' ' '{print $2}'`
wget https://s3-us-west-2.amazonaws.com/hc-enterprise-binaries/vault/ent/1.1.1/vault-enterprise_1.1.1%2Bent_linux_amd64.zip
sudo unzip vault-enterprise_1.1.1+ent_linux_amd64.zip -d /usr/local/bin/

sudo bash -c "cat >/etc/vault.d/vault.hcl" <<EOF
listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "$CLIENT_IP:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

api_addr = "http://$CLIENT_IP:8200"
cluster_addr = "https://$CLIENT_IP:8201"
EOF

# Set Vault up as a systemd service
echo "Installing systemd service for Vault..."
sudo bash -c "cat >/etc/systemd/system/vault.service" << 'EOF'
[Unit]
Description=Vault secret management tool
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
Group=root
PIDFile=/var/run/vault/vault.pid
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl -log-level=debug
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start vault
sudo systemctl enable vault

echo "Installing Consul..."
wget https://s3-us-west-2.amazonaws.com/hc-enterprise-binaries/consul/ent/1.4.4/consul-enterprise_1.4.4%2Bent_linux_amd64.zip
sudo unzip consul-enterprise_1.4.4+ent_linux_amd64.zip -d /usr/local/bin/

# Server configuration
sudo bash -c "cat >/etc/consul.d/consul.json" <<EOF
{
    "datacenter": "dc1",
    "bind_addr": "$CLIENT_IP",
    "data_dir": "/opt/consul",
    "node_name": "consul-vault-${VAULT_ID}",
    "client_addr": "127.0.0.1",
    "retry_join": ["${CONSUL_IP_1}", "${CONSUL_IP_2}", "${CONSUL_IP_3}"],
    "server": false,
    "log_level": "DEBUG",
    "enable_syslog": true,
    "acl_enforce_version_8": false
}
EOF

# Set Consul up as a systemd service
echo "Installing systemd service for Consul..."
sudo bash -c "cat >/etc/systemd/system/consul.service" << 'EOF'
[Unit]
Description=Hashicorp Consul
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=root
Group=root
PIDFile=/var/run/consul/consul.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/consul
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul.d/consul.json -pid-file=/var/run/consul/consul.pid
Restart=on-failure # or always, on-abort, etc
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable consul
sudo systemctl start consul

echo "Configure Consul..."
# sudo printf "DNS=127.0.0.1\nDomains=~consul" >> /etc/systemd/resolved.conf
# sudo iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
# sudo iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
# sudo service systemd-resolved restart

echo "Setting up environment variables..."
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root
echo "export VAULT_ADDR=http://localhost:8200" >> /home/ubuntu/.profile
echo "export VAULT_TOKEN=root" >> /home/ubuntu/.profile
echo "export VAULT_ADDR=http://localhost:8200" >> /root/.profile
echo "export VAULT_TOKEN=root" >> /root/.profile