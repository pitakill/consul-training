#!/bin/bash
# Install Dnsmasq and configure it to forward requests for a specific domain to Consul. This script has been tested
# with the following operating systems:
#
# 1. Ubuntu 16.04
# 2. Amazon Linux
. /etc/environment

set -e

readonly DEFAULT_CONSUL_DOMAIN="consul"
readonly DEFAULT_CONSUL_IP="172.20.20.11"
readonly DEFAULT_CONSUL_DNS_PORT=8600

readonly DNS_MASQ_CONFIG_DIR="/etc/dnsmasq.d"
readonly CONSUL_DNS_MASQ_CONFIG_FILE="$DNS_MASQ_CONFIG_DIR/10-consul"

readonly SCRIPT_NAME="$(basename "$0")"

function print_usage {
  echo
  echo "Usage: install-dnsmasq [OPTIONS]"
  echo
  echo "Install Dnsmasq and configure it to forward requests for a specific domain to Consul. This script has been tested with Ubuntu 16.04 and Amazon Linux."
  echo
  echo "Options:"
  echo
  echo -e "  --consul-domain\tThe domain name to point to Consul. Optional. Default: $DEFAULT_CONSUL_DOMAIN."
  echo -e "  --consul-ip\t\tThe IP address to use for Consul. Optional. Default: $DEFAULT_CONSUL_IP."
  echo -e "  --consul-dns-port\tThe port Consul uses for DNS. Optional. Default: $DEFAULT_CONSUL_DNS_PORT."
  echo
  echo "Example:"
  echo
  echo "  install-dnsmasq"
}

function log {
  local -r level="$1"
  local -r message="$2"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local -r message="$1"
  log "INFO" "$message"
}

function log_warn {
  local -r message="$1"
  log "WARN" "$message"
}

function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}

function assert_not_empty {
  local -r arg_name="$1"
  local -r arg_value="$2"

  if [[ -z "$arg_value" ]]; then
    log_error "The value for '$arg_name' cannot be empty"
    print_usage
    exit 1
  fi
}

function has_yum {
  [[ -n "$(command -v yum)" ]]
}

function has_apt_get {
  [[ -n "$(command -v apt-get)" ]]
}

function install_dnsmasq {
  local -r consul_ip="$1"

  log_info "Installing Dnsmasq"

  if $(has_apt_get); then
    sudo apt-get update -y
    sudo apt-get install -y dnsmasq
  elif $(has_yum); then
    sudo yum update -y
    sudo yum install -y dnsmasq
    echo "prepend domain-name-servers $consul_ip;" | sudo tee -a "/etc/dhcp/dhclient.conf" > /dev/null
    echo "conf-dir=$DNS_MASQ_CONFIG_DIR" | sudo tee -a "/etc/dnsmasq.conf" > /dev/null
    sudo chkconfig dnsmasq on
  else
    log_error "Could not find apt-get or yum. Cannot install on this OS."
    exit 1
  fi
}

function write_consul_config {
  local -r consul_domain="$1"
  local -r consul_ip="$2"
  local -r consul_port="$3"

  log_info "Configuring Dnsmasq to forward lookups of the '$consul_domain' domain to $consul_ip:$consul_port in $CONSUL_DNS_MASQ_CONFIG_FILE"
  mkdir -p "$DNS_MASQ_CONFIG_DIR"

  sudo tee "$CONSUL_DNS_MASQ_CONFIG_FILE" <<EOF
# Enable forward lookup of the '$consul_domain' domain:
server=/${consul_domain}/${DEFAULT_CONSUL_IP}#${consul_port}
server=/${consul_domain}/127.0.0.1#${consul_port}

listen-address=${DEFAULT_CONSUL_IP}
listen-address=127.0.0.1
EOF
}

function install {
  local consul_domain="$DEFAULT_CONSUL_DOMAIN"
  local consul_ip="$DEFAULT_CONSUL_IP"
  local consul_dns_port="$DEFAULT_CONSUL_DNS_PORT"

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --consul-domain)
        assert_not_empty "$key" "$2"
        consul_domain="$2"
        shift
        ;;
      --consul-ip)
        assert_not_empty "$key" "$2"
        consul_ip="$2"
        shift
        ;;
      --consul-dns-port)
        assert_not_empty "$key" "$2"
        consul_dns_port="$2"
        shift
        ;;
      --help)
        print_usage
        exit
        ;;
      *)
        log_error "Unrecognized argument: $key"
        print_usage
        exit 1
        ;;
    esac

    shift
  done

  log_info "Starting Dnsmasq install"
  install_dnsmasq "$consul_ip"
  write_consul_config "$consul_domain" "$consul_ip" "$consul_dns_port"
  log_info "Dnsmasq install complete!"
}

install "$@"

sudo systemctl daemon-reload
sudo /etc/init.d/dnsmasq restart
