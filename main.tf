provider "docker" {}

variable wordpress_port {
  default = "8080"
}

resource "docker_volume" "wordpress_database" {}

resource "docker_network" "wp_net" {
  name = "wp_net"
  ipam_config {
    subnet = "172.16.0.1/16"
  }
}

resource "docker_container" "db" {
  name  = "db"
  image = "mysql:5.7"
  restart = "always"
  network_mode = "wp_net"
  env = [
     "MYSQL_ROOT_PASSWORD=wordpress",
     "MYSQL_PASSWORD=wordpress",
     "MYSQL_USER=wordpress",
     "MYSQL_DATABASE=wordpress"
  ]
  mounts {
    type = "volume"
    target = "/var/lib/mysql"
    source = "wordpress_database"
  }
  provisioner "local-exec" {
    command = "echo ${docker_container.db.ip_address} ${docker_container.db.name}>> ip_list.txt"
  }
}

resource "docker_container" "wordpress" {
  name  = "wordpress"
  image = "wordpress:latest"
  restart = "always"
  network_mode = "wp_net"
  env = [
    "WORDPRESS_DB_HOST=db:3306",
    "WORDPRESS_DB_PASSWORD=wordpress"
  ]
  ports {
    internal = "80"
    external = var.wordpress_port
  }

  provisioner "local-exec" {
    command = "echo ${docker_container.wordpress.ip_address} ${docker_container.wordpress.name}>> ip_list.txt"
  }
}
