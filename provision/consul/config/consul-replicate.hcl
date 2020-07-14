consul {
  address = "nyc.pitakill.net:8500"

  retry {
    attempts = 12
  }

  ssl {
    enabled = true
    verify = true
    ca_cert = "/var/certs/fullchain.pem"
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
