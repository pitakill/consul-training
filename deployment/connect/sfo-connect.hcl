job "counter-connect" {
  datacenters = ["sfo-ncv"]
  region = "sfo-region"
  type = "service"

  group "backend" {
    count = 1

    service {
      name = "backend"
      port = "8080"
      tags = ["${NOMAD_JOB_NAME}"]

      check {
        type = "http"
        port = "http"
        path = "/healthcheck"
        interval = "5s"
        timeout = "2s"
      }

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "redis"
              local_bind_port = 9090
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
        image = "pitakill/consul-training-backend:3.2"
      }

      env {
        REDIS_HOST = "http://${NOMAD_UPSTREAM_IP_redis}"
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
      tags = ["${NOMAD_JOB_NAME}"]

      check {
        type = "http"
        port = "http"
        path = "/"
        interval = "5s"
        timeout = "2s"
      }
    }

    task "frontend" {
      driver = "docker"

      config {
        image = "pitakill/consul-training-frontend:3.0"
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
      tags = ["${NOMAD_JOB_NAME}"]

      connect {
        sidecar_service {}
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:alpine"
      }

      resources {
        cpu = 50
        memory = 50
      }
    }
  }
}
