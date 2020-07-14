#!/bin/bash

. /etc/environment

DIR=/var/consul/config

consul-template -template "$DIR/consul.hcl.tmpl:$DIR/consul.hcl" -once
exec consul agent -config-dir=/var/consul/config/ >>/var/log/consul.log 2>&1
