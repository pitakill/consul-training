data_dir = "/var/consul/config/"
log_level = "DEBUG"

datacenter = "sfo"

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

ports {
  http = 8500
}

advertise_addr = "172.20.20.22"

acl = {
  enabled = true
  default_policy = "deny"
  down_policy = "extend-cache"
}

start_joint = ["172.20.20.11"]
