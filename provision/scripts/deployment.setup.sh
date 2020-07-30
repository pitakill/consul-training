#!/bin/bash

. /etc/environment

d=(connect mesh-gateway service-splitter)

function create_directory {
  mkdir -p "$HOME/$1"
}

function copy_files {
  cp -v /vagrant/deployment/"$1"/*.{hcl,sh} "$HOME/$1" 
}

function create_config {
  template="/vagrant/deployment/$1/$DOMAIN.hcl.tmpl"

  if [[ -f "$template" ]]; then
    consul-template -template "$template:$HOME/$1/$DOMAIN.hcl" -once
  fi
}

for t in "${d[@]}"
do
  create_directory "${t}"
  copy_files "${t}"
  create_config "${t}"
done
