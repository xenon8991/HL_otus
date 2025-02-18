
terraform {
  required_version = "= 1.9.8"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
#  token     = var.yc_token
  zone      = var.zone
  service_account_key_file = var.service_account_key_file
}

resource "yandex_compute_instance" "HL-1" {
  name = "hl-tef-1"
  resources {
    cores = 2
    memory = 2
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
    image_id = "fd85hkli5dp6as39ali4"
    size = 20
    type = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.hl-subnet-1.id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host        = yandex_compute_instance.HL-1.network_interface.0.nat_ip_address
  }
}
resource "yandex_vpc_network" "network1" {
name = "hl-network-1"
}

resource "yandex_vpc_subnet" "hl-subnet-1" {
network_id = "${yandex_vpc_network.network1.id}"
v4_cidr_blocks = ["192.168.100.0/24"]
zone           = var.zone
}
output "internal_ip_address_HL-1" {
  value = yandex_compute_instance.HL-1.network_interface.0.ip_address
}

output "external_ip_address_HL-1" {
  value = yandex_compute_instance.HL-1.network_interface.0.nat_ip_address
}
