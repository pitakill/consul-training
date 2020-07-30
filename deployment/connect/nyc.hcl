job "counter-connect" {
  meta {
    backend_image = "pitakill/consul-training-backend"
    backend_version = "3.5"

    frontend_image = "pitakill/consul-training-frontend"
    frontend_version = "3.6"

    database_image = "redis"
    database_version = "alpine"
  }

  datacenters = ["nyc-ncv"]
  region = "nyc-region"
  type = "service"

  group "backend" {
    count = 1

    service {
      name = "backend"
      port = "backend"
      tags = [
        "${NOMAD_JOB_NAME}",
        "${NOMAD_META_backend_image}:${NOMAD_META_backend_version}"
      ]

      check {
        type     = "http"
        path     = "/healthcheck"
        port     = "backend"
        interval = "10s"
        timeout  = "2s"
      }

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

      port "backend" {
        static = 8080
      }
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

      port "frontend" {
        static = 80
        to = 80
      }
    }

    service {
      name = "frontend"
      port = "frontend"
      tags = [
        "${NOMAD_JOB_NAME}",
        "${NOMAD_META_frontend_image}:${NOMAD_META_frontend_version}"
      ]

      check {
        type     = "http"
        path     = "/"
        port     = "frontend"
        interval = "10s"
        timeout  = "2s"
      }

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

      port "database" {
        static = 6379
      }
    }

    service {
      name = "redis"
      port = "database"
      tags = [
        "${NOMAD_JOB_NAME}",
        "${NOMAD_META_database_image}:${NOMAD_META_database_version}"
      ]

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
