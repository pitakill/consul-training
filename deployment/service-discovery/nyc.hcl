job "counter" {
  datacenters = ["nyc-ncv"]
  region = "nyc-region"
  type = "service"

  meta {
    backend_image = "pitakill/consul-training-backend"
    backend_version = "3.2"

    frontend_image = "pitakill/consul-training-frontend"
    frontend_version = "3.0"

    database_version = "alpine"
    database_image = "redis"
  }

  group "backend" {
    count = 1

    service {
      name = "backend"
      port = "http"
      tags = ["${NOMAD_JOB_NAME}", "${NOMAD_META_backend_image}:${NOMAD_META_backend_version}"]

      check {
        type = "http"
        port = "http"
        path = "/healthcheck"
        interval = "5s"
        timeout = "2s"
      }
    }

    network {
      mode = "bridge"
      port "http" {
        static = 8080
        to = 8080
      }
    }

    task "backend" {
      driver = "docker"

      config = {
        image = "${NOMAD_META_backend_image}:${NOMAD_META_backend_version}"
      }

      env {
        REDIS_HOST = "redis.service.consul"
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

      port "redis" {
        static = 6379
        to = 6379
      }
    }

    service {
      name = "redis"
      port = "redis"
      tags = ["${NOMAD_JOB_NAME}", "${NOMAD_META_database_image}:${NOMAD_META_database_version}"]
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
