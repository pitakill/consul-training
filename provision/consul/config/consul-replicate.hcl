consul {
  address = "nyc.pitakill.net:8501"

  retry {
    attempts = 12
  }

  ssl {
    enabled = true
    verify = true
    ca_cert = "/vagrant/provision/certs/fullchain1.pem"
  }
}

log_level = "debug"

prefix {
  source = "app"
  datacenter = "sfo"
  destination = "app"
}

prefix {
  source = "app2"
  datacenter = "sfo"
  destination = "app2"
}
