job "counter" {
  datacenters = ["sfo-ncv"]
  region = "sfo-region"
  type = "service"

  group "backend" {
    count = 1

    service {
      name = "backend"
      port = "http"
      tags = ["${NOMAD_JOB_NAME}"]

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
        image = "pitakill/consul-training-backend:2.0"
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

      port "redis" {
        static = 6379
        to = 6379
      }
    }

    service {
      name = "redis"
      port = "redis"
      tags = ["${NOMAD_JOB_NAME}"]
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
