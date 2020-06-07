provider "docker" {}

variable wordpress_port {
  default = "8080"
}

resource "docker_volume" "mysql_volume" {}

resource "docker_network" "local_network" {
  name = "local_network"
  ipam_config {
    subnet = "172.16.0.1/16"
  }
}

resource "docker_container" "database" {
  name  = "database"
  image = "mysql:5.7"
  restart = "always"
  network_mode = "local_network"
  env = [
     "MYSQL_ROOT_PASSWORD=wordpress",
     "MYSQL_PASSWORD=wordpress",
     "MYSQL_USER=wordpress",
     "MYSQL_DATABASE=wordpress"
  ]
  mounts {
    type = "volume"
    target = "/var/lib/mysql"
    source = "mysql_volume"
  }
}

resource "docker_container" "wordpress" {
  name  = "wordpress"
  image = "wordpress:latest"
  restart = "always"
  network_mode = "local_network"
  env = [
    "WORDPRESS_DB_HOST=db:3306",
    "WORDPRESS_DB_PASSWORD=wordpress"
  ]
  ports {
    internal = "80"
    external = var.wordpress_port
  }
}
