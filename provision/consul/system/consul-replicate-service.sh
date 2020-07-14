#!/bin/bash

. /etc/environment

if [ "$DATACENTER" != "sfo" ] && [ "$SERVER" == "true" ]; then
  exec consul-replicate -config /vagrant/provision/consul/config/consul-replicate.hcl >> /var/log/consul-replicate.log 2>&1
fi
