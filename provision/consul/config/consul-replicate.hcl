consul {
  address = "172.20.20.21:8500"

  retry {
    attempts = 12
  }

  ssl {
    enabled = true
    verify = true
    ca_cert = "/var/certs/consul-agent-ca.pem"
  }
}

log_level = "debug"

prefix {
  source = "cluster/global"
  datacenter = "sfo"
  destination = "cluster/global"
}

prefix {
  source = "cluster/app"
  datacenter = "sfo"
  destination = "cluster/app"
}
