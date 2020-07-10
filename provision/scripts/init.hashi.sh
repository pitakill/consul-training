#!/bin/bash

tools=(consul nomad vault)
OUTSIDE="/vagrant/provision"
LOCAL_ENV_DIR="/etc/environment"

function copy_templates {
  local output="/var/$1/config"
  sudo mkdir -p "$output"
  sudo cp "$OUTSIDE/$1/config/"*.hcl.tmpl "$output"
}

function copy_services {
  local output="/etc/systemd/system"
  sudo cp "$OUTSIDE/$1/system/"*.service "$output/"
}

function setup_environment {
  sudo cp "$OUTSIDE/scripts/envs.sh" "$LOCAL_ENV_DIR"

  sudo sed -i "s/@data_centers/'[\"172.20.20.11\",\"172.20.20.21\"]'/" "$LOCAL_ENV_DIR"
  sudo sed -i "s/@data_center/$1/g" "$LOCAL_ENV_DIR"
  sudo sed -i "s/@ip_address/$2/g" "$LOCAL_ENV_DIR"
  sudo sed -i "s/@server_ip/$4/g" "$LOCAL_ENV_DIR"
  sudo sed -i "s/@server/$3/g" "$LOCAL_ENV_DIR"
  sudo sed -i "s/@primary_dc/sfo/g" "$LOCAL_ENV_DIR"
  sudo sed -i "s/@secondary_dc/nyc/g" "$LOCAL_ENV_DIR"
}

# Setup
for t in "${tools[@]}"
do
  copy_templates "${t}"
  copy_services "${t}"
done
setup_environment "$@"
