#!/bin/bash

CONSUL_DIR="/vagrant/provision/consul"
VAGRANT_CONFIG_DIR="$CONSUL_DIR/config"
VAGRANT_SYSTEM_DIR="$CONSUL_DIR/system"

LOCAL_CONFIG_DIR="/var/consul/config"
LOCAL_SYSTEM_DIR="/etc/systemd/system"

LOCAL_ENV_DIR="/etc/environment"

sudo cp "$VAGRANT_CONFIG_DIR/envs.sh" "$LOCAL_ENV_DIR"
sudo sed -i "s/@data_center/$1/g" "$LOCAL_ENV_DIR"
sudo sed -i "s/@ip_address/$2/g" "$LOCAL_ENV_DIR"
sudo sed -i "s/@server_ip/$4/g" "$LOCAL_ENV_DIR"
sudo sed -i "s/@server/$3/g" "$LOCAL_ENV_DIR"

sudo mkdir -p "$LOCAL_CONFIG_DIR"

# Setup Consul Files
. "$LOCAL_ENV_DIR"
sudo -E consul-template -template "$VAGRANT_CONFIG_DIR/consul.hcl.tmpl:$LOCAL_CONFIG_DIR/consul.hcl" -once
sudo cp "$VAGRANT_CONFIG_DIR/services.json" "$LOCAL_CONFIG_DIR/services.json"
sudo cp "$VAGRANT_SYSTEM_DIR/consul.service" "$LOCAL_SYSTEM_DIR/consul.service"
sudo chmod -R +x "$LOCAL_CONFIG_DIR"
sudo chmod -R +x "$VAGRANT_SYSTEM_DIR"
