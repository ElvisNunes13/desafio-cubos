terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Variáveis
variable "POSTGRES_USER" {
  type    = string
  default = "admin"
}

variable "POSTGRES_PASSWORD" {
  type    = string
  default = "secret"
}

variable "POSTGRES_DB" {
  type    = string
  default = "desafio"
}

variable "POSTGRES_PORT" {
  type    = number
  default = 5432
}

variable "BACKEND_PORT" {
  type    = number
  default = 3001
}

# Redes
resource "docker_network" "frontend_net" {
  name = "frontend_net"
}

resource "docker_network" "backend_net" {
  name = "backend_net"
}

# Volume do banco
resource "docker_volume" "pgdata" {
  name = "pgdata"
}

# PostgreSQL

resource "docker_container" "postgres" {
  name  = "postgres"
  image = "postgres:15.8"

  env = [
    "POSTGRES_USER=${var.POSTGRES_USER}",
    "POSTGRES_PASSWORD=${var.POSTGRES_PASSWORD}",
    "POSTGRES_DB=${var.POSTGRES_DB}"
  ]

  mounts {
    target = "/var/lib/postgresql/data"
    source = docker_volume.pgdata.name
    type   = "volume"
  }

  mounts {
    target = "/docker-entrypoint-initdb.d/init.sql"
    source = abspath("${path.module}/../database/init.sql")
    type   = "bind"
  }

  networks_advanced {
    name = docker_network.backend_net.name
  }
}

# Backend

resource "docker_image" "backend" {
  name = "backend:latest"
  build {
    context = abspath("${path.module}/../backend")
  }
}

resource "docker_container" "backend" {
  name  = "backend"
  image = docker_image.backend.name

  env = [
    "PORT=${var.BACKEND_PORT}",
    "POSTGRES_USER=${var.POSTGRES_USER}",
    "POSTGRES_PASSWORD=${var.POSTGRES_PASSWORD}",
    "POSTGRES_HOST=postgres",
    "POSTGRES_PORT=${var.POSTGRES_PORT}",
    "POSTGRES_DB=${var.POSTGRES_DB}"
  ]

  networks_advanced {
    name = docker_network.backend_net.name
  }

  restart = "always"

    depends_on = [
    docker_container.postgres
  ]
}

# Nginx (Frontend + Proxy)

resource "docker_image" "frontend" {
  name = "frontend:latest"
  build {
    context = abspath("${path.module}/../frontend")
  }
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.frontend.name

  ports {
    internal = 80
    external = 80
  }

  networks_advanced {
    name = docker_network.frontend_net.name
  }

  networks_advanced {
    name = docker_network.backend_net.name
  }

  restart = "always"

  mounts {
    target = "/etc/nginx/nginx.conf"
    source = abspath("${path.module}/../nginx/nginx.conf")
    type   = "bind"
  }
}
