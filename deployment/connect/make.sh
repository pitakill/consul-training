#!/bin/bash

. /etc/environment

d="$HOME/connect"
job=connect

function deploy {
  nomad run "$d/$DATACENTER.hcl"

  consul intention create -allow frontend backend
  consul intention create -allow backend database

  # for file in "$d"/*service*.hcl; do
    # consul config write "$file"
  # done
}

function undeploy {
  nomad stop -purge "$job"

  consul intention delete frontend backend
  consul intention delete backend database

  # consul config delete -kind service-defaults -name backend
  # consul config delete -kind service-resolver -name backend
  # consul config delete -kind service-splitter -name backend
}

if [[ "$1" != "" ]];then
  "$1"
else
  echo "Use this script with 'deploy' or 'undeploy'"
fi
