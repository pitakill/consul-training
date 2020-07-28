job "counter-connect" {
  meta {
    backend_image = "pitakill/consul-training-backend"
    backend_version = "3.4"

    frontend_image = "pitakill/consul-training-frontend"
    frontend_version = "3.5"

    database_image = "redis"
    database_version = "alpine"
  }

  datacenters = ["sfo-ncv"]
  region = "sfo-region"
  type = "service"

  group "backend" {
    count = 1

    service {
      name = "backend"
      port = "8080"
      tags = ["${NOMAD_JOB_NAME}", "${NOMAD_META_backend_image}:${NOMAD_META_backend_version}"]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "redis"
              local_bind_port = 6379
            }
          }
        }
      }
    }

    network {
      mode = "bridge"
    }

    task "backend" {
      driver = "docker"

      config = {
        image = "${NOMAD_META_backend_image}:${NOMAD_META_backend_version}"
      }

      resources = {
        cpu = 50
        memory = 50
      }
    }
  }

  group "frontend" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        static = 80
        to = 80
      }
    }

    service {
      name = "frontend"
      port = "http"
      tags = ["${NOMAD_JOB_NAME}", "${NOMAD_META_frontend_image}:${NOMAD_META_frontend_version}"]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "backend"
              local_bind_port = 8080
            }
          }
        }
      }
    }

    task "frontend" {
      driver = "docker"

      config {
        image = "${NOMAD_META_frontend_image}:${NOMAD_META_frontend_version}"
      }

      resources {
        cpu = 50
        memory = 50
      }
    }
  }

  group "database" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "redis"
      port = "6379"
      tags = ["${NOMAD_JOB_NAME}", "${NOMAD_META_database_image}:${NOMAD_META_database_version}"]

      connect {
        sidecar_service {}
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "${NOMAD_META_database_image}:${NOMAD_META_database_version}"
      }

      resources {
        cpu = 50
        memory = 50
      }
    }
  }
}
