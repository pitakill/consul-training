#!/bin/bash

. /etc/environment

d="$HOME/service-splitter"
job=splitter

function deploy {
  nomad run "$d/$DATACENTER.hcl"

  for file in "$d"/*service*; do
    consul config write "$file"
  done
}

function undeploy {
  nomad stop -purge "$job"

  consul config delete -kind service-splitter -name backend-splitter
  consul config delete -kind service-defaults -name backend-splitter
  consul config delete -kind service-defaults -name database-splitter
  consul config delete -kind service-resolver -name backend-splitter
  consul config delete -kind service-resolver -name database-splitter
}

if [[ "$1" != "" ]];then
  "$1"
else
  echo "Use this script with 'deploy' or 'undeploy'"
fi
