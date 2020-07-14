#!/bin/bash

. /etc/environment

NOMAD_DIR=/var/nomad/config
DOCKER_DIR=/etc/docker

consul-template -template "$DOCKER_DIR/daemon.json.tmpl:$DOCKER_DIR/daemon.json" -once
consul-template -template "$NOMAD_DIR/nomad.hcl.tmpl:$NOMAD_DIR/nomad.hcl" -once
exec nomad agent -config /var/nomad/config >>/var/log/nomad.log 2>&1
