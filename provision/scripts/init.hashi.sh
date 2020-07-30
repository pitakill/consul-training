#!/bin/bash

tools=(consul nomad)
OUTSIDE="/vagrant/provision"

function copy_certificates {
  local output="/var/certs"
  sudo cp -r "$OUTSIDE/certs" /var/certs
  sudo chown -R 1000:1000 "$output"
}

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
  local output="/etc/environment"
  sudo cp "$OUTSIDE/scripts/envs.sh" "$output"

  sudo sed -i "s/@data_centers/'[\"172.20.20.11\",\"172.20.20.21\"]'/" "$output"
  sudo sed -i "s/@data_center/$1/g" "$output"
  sudo sed -i "s/@ip_address/$2/g" "$output"
  sudo sed -i "s/@server_ip/$5/g" "$output"
  sudo sed -i "s/@server/$3/g" "$output"
  sudo sed -i "s/@domain/$4/g" "$output"
  sudo sed -i "s/@primary_dc/sfo/g" "$output"
  sudo sed -i "s/@secondary_dc/nyc/g" "$output"

  # Environment for docker inside the vms
  local docker_output="/etc/docker"
  sudo cp "$OUTSIDE/docker/daemon.json.tmpl" "$docker_output/daemon.json.tmpl"
}

function start_tool {
  sudo systemctl daemon-reload
  sudo systemctl restart "$1"
  sudo systemctl enable "$1"
}

function bootstrap {
  # Bootstrap only servers
  if [ "$3" == "true" ]; then
    # Bootstrap only principal consul for storage the root token
    if [ "$1" == "sfo" ]; then 
      sudo bash "$OUTSIDE/consul/system/bootstrap.sh"
      return
    fi

    # Bootstrap only secondaries
    if [ "$1" != "sfo" ]; then
      sudo systemctl restart consul-replicate
    fi
  fi

  sudo bash "$OUTSIDE/scripts/init.secondaries.sh"
}

# Setup
setup_environment "$@"
copy_certificates
for t in "${tools[@]}"
do
  copy_templates "${t}"
  copy_services "${t}"
  start_tool "${t}"
done
bootstrap "$@"
for t in "${tools[@]}"
do
  start_tool "${t}"
done
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
bash $OUTSIDE/scripts/deployment.setup.sh
