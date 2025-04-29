provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_volume" "web_data" {
  name       = "web-data-volume"
  region     = "sgp1"
  size       = 160
  filesystem_type = "ext4"
}

resource "digitalocean_firewall" "allow_all" {
  name = "allow-all-traffic"

  droplet_ids = [digitalocean_droplet.web_container_host.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "0-65535"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "0-65535"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol           = "tcp"
    port_range         = "0-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol           = "udp"
    port_range         = "0-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol           = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_droplet" "web_container_host" {
  name              = "web-container-host"
  region            = "sgp1"
  size              = "s-4vcpu-8gb"
  image             = "ubuntu-22-04-x64"
  ipv6              = true
  private_networking = true
  volume_ids        = [digitalocean_volume.web_data.id]
  vpc_uuid          = data.digitalocean_vpc.default.id

  tags = ["web", "container", "devops"]
}

# Get the default VPC in SGP1
data "digitalocean_vpc" "default" {
  name = "default-sgp1"
  region = "sgp1"
}

