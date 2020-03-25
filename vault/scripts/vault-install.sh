#!/bin/sh
# Configures the Vault server for a database secrets demo

# cd /tmp
echo "Preparing to install Vault..."
sudo apt-get -y update > /dev/null 2>&1

# Grub Bootloader issue, commenting out for now
# sudo apt-get -y upgrade > /dev/null 2>&1

sudo apt install -y unzip jq mysql-client > /dev/null 2>&1

mkdir -p /etc/vault.d
mkdir -p /etc/consul.d
mkdir -p /root/.aws
mkdir -p /root/ca

if [ $AUTO_HTTPS -eq 1 ]; then
    export HTTP_PROTOCOL="https"
else
    export HTTP_PROTOCOL="http"
fi

echo "Writing AWS credentials..."
sudo bash -c "cat >/root/.aws/config" <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY}
aws_secret_access_key=${AWS_SECRET_KEY}
EOF
sudo bash -c "cat >/root/.aws/credentials" <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY}
aws_secret_access_key=${AWS_SECRET_KEY}
EOF

# Copy our LetsEncrypt cert into file
sudo bash -c "cat >/root/ca/vault.crt" <<EOF
${TLS_CERT}
EOF

# Copy our LetsEncrypt private key into file
sudo bash -c "cat >/root/ca/vault.key" <<EOF
${TLS_PRIVATE_KEY}
EOF

echo "Waiting for Consul cluster to be available..."
while [ "200" -ne "$(curl -s -o /dev/null -w \"%%{http_code}\" http://${PRIMARY_CONSUL_IP}:8500/v1/status/leader)" ]; do
    sleep 3
    echo "...still waiting for Consul cluster..."
done
echo "Consul is now ready."


echo "Installing Consul..."
export CLIENT_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
export PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
curl -sfLo "consul.zip" "${CONSUL_DL_URL}"
sudo unzip consul.zip -d /usr/local/bin/

# Server configuration
echo "Creating Consul configuration..."
sudo bash -c "cat >/etc/consul.d/consul.json" <<EOF
{
    "datacenter": "${AWS_REGION}",
    "bind_addr": "$CLIENT_IP",
    "data_dir": "/opt/consul",
    "node_name": "consul-vault-${VAULT_ID}",
    "client_addr": "127.0.0.1",
    "retry_join": ["provider=aws tag_key=${CONSUL_JOIN_KEY} tag_value=${CONSUL_JOIN_VALUE} region=${AWS_REGION}"],
    "server": false,
    "log_level": "DEBUG",
    "enable_syslog": true,
    "acl_enforce_version_8": false
}
EOF

# Set Consul up as a systemd service
echo "Installing systemd service for Consul..."
sudo bash -c "cat >/etc/systemd/system/consul.service" <<EOF
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

echo "Enabling and Starting Consul..."
sudo systemctl enable consul
sudo systemctl start consul

echo "Waiting for Consul to come online..."
while [ -z "$(curl -s http://127.0.0.1:8500/v1/status/leader)" ]; do
    sleep 3
    echo "...still waiting for Consul..."
done
echo "Consul is now ready."


echo "Installing Vault..."
curl -sfLo "vault.zip" "${VAULT_DL_URL}"
sudo unzip vault.zip -d /usr/local/bin/

echo "Creating Vault configuration..."
sudo bash -c "cat >/etc/vault.d/vault.hcl" <<EOF
storage "consul" {
    path            = "vault/"
}
EOF

if [ "${AUTO_HTTPS}" -eq 1 ]; then
sudo bash -c "cat >>/etc/vault.d/vault.hcl" <<EOF
listener "tcp" {
    address         = "$CLIENT_IP:8200"
    # tls_skip_verify = 1
    tls_cert_file   = "/root/ca/vault.crt"
    tls_key_file    = "/root/ca/vault.key"
}
EOF
else
sudo bash -c "cat >>/etc/vault.d/vault.hcl" <<EOF
listener "tcp" {
    address         = "$CLIENT_IP:8200"
    tls_disable     = 1
}
EOF
fi

sudo bash -c "cat >>/etc/vault.d/vault.hcl" <<EOF
seal "awskms" {
      region        = "${AWS_REGION}"
      kms_key_id    = "${AWS_KMS_KEY_ID}"
}

api_addr = "$HTTP_PROTOCOL://$PUBLIC_IP:8200"
ui = true
EOF

# echo "Creating self-signed certificate configuration file..."
# sudo bash -c "cat >/root/ca/openssl.cnf" <<EOF
# [req]
# distinguished_name = req_distinguished_name
# x509_extensions = v3_req
# prompt = no

# [req_distinguished_name]
# C = US
# ST = Georgia
# L =  Atlanta
# O = HashiCorp
# CN = *

# [v3_req]
# subjectKeyIdentifier = hash
# authorityKeyIdentifier = keyid,issuer
# basicConstraints = CA:TRUE
# subjectAltName = @alt_names

# [alt_names]
# DNS.1 = *
# DNS.2 = *.*
# DNS.3 = *.*.*
# DNS.4 = *.*.*.*
# DNS.5 = *.*.*.*.*
# DNS.6 = *.*.*.*.*.*
# DNS.7 = *.*.*.*.*.*.*
# IP.1 = $CLIENT_IP
# IP.2 = $PUBLIC_IP
# EOF

# echo "Creating the self-signed certification..."
# openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout /root/ca/vault.key -out /root/ca/vault.crt -config /root/ca/openssl.cnf -days 9999
# cat /root/ca/vault.crt >> /etc/ssl/certs/ca-certificates.crt

# Set Vault up as a systemd service
echo "Installing systemd service for Vault..."
sudo bash -c "cat >/etc/systemd/system/vault.service" <<EOF
[Unit]
Description=HashiCorp Vault
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
Group=root
PIDFile=/var/run/vault/vault.pid
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl -log-level=debug -tls-skip-verify
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

echo "Setting up environment variables..."
export VAULT_ADDR=$HTTP_PROTOCOL://$CLIENT_IP:8200

echo "Vault ID is ${VAULT_ID}"
if [ ${VAULT_ID} -eq 1 ]; then
    sleep 10
    echo "Waiting for Consul..."

    while [ -z "$(curl -s http://127.0.0.1:8500/v1/status/leader)" ]; do
        sleep 2
    done

    while [ -z "$(curl -s $VAULT_ADDR/v1/status)" ]; do
        sleep 2
    done

    echo "Initializing Vault..."
    vault operator init -recovery-shares=1 -recovery-threshold=1 -key-shares=1 -key-threshold=1 > /root/init.txt 2>&1

    echo $(cat /root/init.txt)
    export VAULT_TOKEN=`cat /root/init.txt | sed -n -e '/^Initial Root Token/ s/.*\: *//p'`
    consul kv put service/vault/root-token $VAULT_TOKEN
    export RECOVERY_KEY=`cat /root/init.txt | sed -n -e '/^Recovery Key 1/ s/.*\: *//p'`
    consul kv put service/vault/recovery-key $RECOVERY_KEY
fi

echo "Setting up environment..."
echo "export VAULT_ADDR=$HTTP_PROTOCOL://$CLIENT_IP:8200" >> /home/ubuntu/.profile
echo "export VAULT_TOKEN=$VAULT_TOKEN" >> /home/ubuntu/.profile
echo "export VAULT_ADDR=$HTTP_PROTOCOL://$CLIENT_IP:8200" >> /root/.profile
echo "export VAULT_TOKEN=$VAULT_TOKEN" >> /root/.profile

if [ ${VAULT_ID} -eq 1 ]; then
    echo "Licensing Vault..."
    vault write sys/license text=${VAULT_LICENSE}
fi

echo "Vault installation complete!"

if [ "${VAULT_PRIMARY_REGION}" = "${AWS_REGION}" ] && [ "${VAULT_ID}" -eq 1 ] ; then 
    echo "Primary Cluster"

    echo "Secondary Cluster IP: ${SECONDARY_CONSUL_IP}"

    if [ "${VAULT_REPLICATION_TYPE}" = "dr" ]; then 
        echo "Enabling DR Replication"
        vault write -f sys/replication/dr/primary/enable
        export VAULT_SECONDARY_TOKEN="$(vault write sys/replication/dr/primary/secondary-token id="secondary-1" | grep -oP 'wrapping_token:[ ]*\K.*')"
    else
        echo "Enabling Performance Replication"
        vault write -f sys/replication/performance/primary/enable
        export VAULT_SECONDARY_TOKEN="$(vault write sys/replication/performance/primary/secondary-token id="secondary-1" | grep -oP 'wrapping_token:[ ]*\K.*')"
    fi
    consul kv put vault_primary_cluster_ip $PUBLIC_IP
    consul kv put vault_secondary_token $VAULT_SECONDARY_TOKEN
elif [ "${VAULT_PRIMARY_REGION}" != "${AWS_REGION}" ] && [ "${VAULT_ID}" -eq 1 ]; then 
    echo "Secondary Cluster"

    echo "Secondary Cluster IP: ${PRIMARY_CONSUL_IP}"

    if [ "${VAULT_REPLICATION_TYPE}" = "dr" ]; then 
        echo "Enabling DR Replication"

        echo "Waiting for Secondary Token"
        while [ -z "$(curl -s http://${PRIMARY_CONSUL_IP}:8500/v1/kv/vault_secondary_token)" ]; do
            sleep 2
        done
        echo "Secondary Token Received"

        vault write sys/replication/dr/secondary/enable \
            token="$(curl -s http://${PRIMARY_CONSUL_IP}:8500/v1/kv/vault_secondary_token | jq -r '.[0].Value' | base64 --decode)" \
            primary_api_addr="http://$(curl -s http://${PRIMARY_CONSUL_IP}:8500/v1/kv/vault_primary_cluster_ip | jq -r '.[0].Value' | base64 --decode):8200"

        echo "Secondary Token Written"

    else
        echo "Enabling Performance Replication"

        echo "Waiting for Secondary Token"
        while [ -z "$(curl -s http://${PRIMARY_CONSUL_IP}:8500/v1/kv/vault_secondary_token)" ]; do
            sleep 2
        done
        echo "Secondary Token Received"

        vault write sys/replication/performance/secondary/enable \
            token="$(curl -s http://${PRIMARY_CONSUL_IP}:8500/v1/kv/vault_secondary_token | jq -r '.[0].Value' | base64 --decode)" \
            primary_api_addr="http://$(curl -s http://${PRIMARY_CONSUL_IP}:8500/v1/kv/vault_primary_cluster_ip | jq -r '.[0].Value' | base64 --decode):8200"

        echo "Secondary Token Written"
    fi

fi
