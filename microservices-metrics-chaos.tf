resource "digitalocean_droplet" "digital-ocean-droplet" {
    image = "ubuntu-18-04-x64"
    name = "digital-ocean-droplet"
    region = "sgp1"
    size = "s-1vcpu-2gb"
    private_networking = true
    ssh_keys = [
      var.ssh_fingerprint
    ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install python3-pip
      "sudo apt-get update",
      "sudo apt-get -y install python3-pip"
    ]
  }
}

resource "digitalocean_kubernetes_cluster" "digital-ocean-cluster" {
  name    = "digital-ocean-cluster"
  region  = "sgp1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.18.3-do.0"

  node_pool {
    name       = "digital-ocean-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}
