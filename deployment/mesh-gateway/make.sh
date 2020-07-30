#!/bin/bash

. /etc/environment

d="$HOME/mesh-gateway"
job=app

function deploy {
  nomad run "$d/$DATACENTER.hcl"

  for file in "$d"/*service*; do
    consul config write "$file"
  done
}

function undeploy {
  nomad stop -purge "$job"

  consul config delete -kind service-defaults -name backend-mesh
  consul config delete -kind service-resolver -name backend-mesh
}

if [[ "$1" != "" ]];then
  "$1"
else
  echo "Use this script with 'deploy' or 'undeploy'"
fi
