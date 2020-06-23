#!/bin/bash

sudo mkdir -p /var/consul/config

# Setup Consul Files
sudo cp /vagrant/provision/consul/config/* /var/consul/config/
sudo cp /vagrant/provision/consul/system/consul.service /etc/systemd/system/consul.service
sudo chmod -R +x /var/consul/config/
sudo chmod -R +x /vagrant/provision/consul/system/
