#!/bin/bash

# certs
CERTS_DIR=/var/certs
CA_CERT=consul-agent-ca.pem
CERT=@data_center-server-consul-0.pem
KEY=@data_center-server-consul-0-key.pem

# local vars
CONSUL_SCHEME=https

export DATACENTERS=@data_centers
export DATACENTER=@data_center
export IP_ADDRESS=@ip_address
export SERVER_IP=@server_ip
export SERVER=@server
export PRIMARY_DATACENTER=@primary_dc
export SECONDARY_DATACENTER=@secondary_dc
export DOMAIN=@domain

# Consul env vars
export CONSUL_SERVERS=1
export CONSUL_PORT=8500
export CONSUL_HTTP_ADDR="$CONSUL_SCHEME://$IP_ADDRESS:$CONSUL_PORT"
export CONSUL_HTTP_ADDR_PRINCIPAL="$CONSUL_SCHEME://172.20.20.11:$CONSUL_PORT"
export CONSUL_CACERT="$CERTS_DIR/$CA_CERT"
export CONSUL_CLIENT_CERT="$CERTS_DIR/$CERT"
export CONSUL_CLIENT_KEY="$CERTS_DIR/$KEY"
export CONSUL_ENCRYPT_KEY="apEfb4TxRk3zGtrxxAjIkwUOgnVkaD88uFyMGHqKjIw="
export CONSUL_SSL=true

# Nomad env vars
export NOMAD_CACERT="$CERTS_DIR/$CA_CERT"
export NOMAD_CLIENT_CERT="$CERTS_DIR/$CERT"
export NOMAD_CLIENT_KEY="$CERTS_DIR/$KEY"
export NOMAD_SERVERS=1
export NOMAD_ADDR="$CONSUL_SCHEME://$IP_ADDRESS:4646"
