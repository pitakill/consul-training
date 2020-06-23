data_dir = "/var/consul/config/"
log_leve = "DEBUG"

datacenter = "sfo"

ui = true
server = true
bootstrap_expect = 1

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

ports {
  http = 8200
}

advertise_addr = "172.20.20.11"

acl = {
  enable = true
  default_policy = "deny"
  down_policy = "extend-cache"
}
