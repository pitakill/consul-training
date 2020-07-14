#!/bin/bash

function configure_systemd {
  sudo tee -a /etc/systemd/resolved.conf > /dev/null <<EOT
DNS=127.0.0.1
Domains=~consul
EOT
}

function configure_iptables {
  sudo iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
  sudo iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
}

configure_systemd
configure_iptables
sudo systemctl restart systemd-resolved.service
