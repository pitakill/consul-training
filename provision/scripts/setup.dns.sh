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

function configure_dnsmasq {
  local -r consul_config_file=/etc/dnsmasq.d/10-consul

  echo "interface=docker0" | sudo tee -a "/etc/dnsmasq.conf" > /dev/null
  echo "bind-interfaces" | sudo tee -a "/etc/dnsmasq.conf" > /dev/null
  echo "conf-dir=/etc/dnsmasq.d" | sudo tee -a "/etc/dnsmasq.conf" > /dev/null
  sudo touch "$consul_config_file"
  sudo tee "$consul_config_file" <<EOF
server=/consul/127.0.0.1#8600
server=/consul/$1#8600

listen-address=127.0.0.1
listen-address=$1
EOF
}

configure_systemd
configure_dnsmasq "$@"
sudo systemctl daemon-reload
sudo systemctl restart systemd-resolved.service dnsmasq.service
