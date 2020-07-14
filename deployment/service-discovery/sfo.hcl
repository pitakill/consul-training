job "counter" {
  datacenters = ["sfo-ncv"]
  region = "sfo-region"
  type = "service"

  group "backend" {
    count = 1

    task "backend" {
      driver = "docker"
      config = {
        image = "pitakill/consul-training-backend:3.0"
      }

      resources = {
        cpu = 50
        memory = 50

        network {
          mode = "bridge"
          port "http" {
            static = 8080
            to = 8080
          }
        }
      }

      service {
        name = "backend"
        port = "http"
        tags = ["${NOMAD_JOB_NAME}"]
      }
    }
  }

  group "frontend" {
    count = 1

    task "frontend" {
      driver = "docker"
      config {
        image = "pitakill/consul-training-frontend"
      }

      resources {
        cpu = 50
        memory = 50

        network {
          mode = "bridge"
          port "http" {
            static = 80
            to = 80
          }
        }
      }

      service {
        name = "frontend"
        port = "http"
        tags = ["${NOMAD_JOB_NAME}"]
      }
    }
  }
}
