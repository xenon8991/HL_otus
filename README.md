# ход выполнения домашнего задания №1
## Окружение
Рабочая станиция - Windows
Terraform - ver 1.9.8  
## Подготовка рабочей машины
- Регистрация в YC, создание сервис-аккаунта 
- Установлен Terraform для Windows() 
- Внесены изменения в `terraform.rc` для подмены адреса `registry.terraform.io` на `terraform-mirror.yandexcloud.net`
- Созданы файлы `main.tf` и `variables.tf`
## Создание скрипта terraform main.tf
- Добавлен раздел terraform
```
terraform {
  required_version = "= 1.9.8"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
```
- Добавлен раздел с параметрами провайдера
```
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  service_account_key_file = var.service_account_key_file
}
```
- Добавлен раздел с используемыми ресурсами
``` 
resource "yandex_compute_instance" "HL-1" {
  name = "hl-tef-1"
  resources { # блок настройки выделяемых ресурсов
    cores = 2 # Указано количество ядер
    memory = 2 # Указано количество оперативной памяти в ГБ
    core_fraction = 5
  }
  boot_disk { # блок настройки выделяемых дисков
    initialize_params {
    image_id = "fd85hkli5dp6as39ali4" # Указан id образа ubuntu 24.04 LTS
    size = 20 # Указан объем первого диска 20 ГБ
    type = "network-hdd"
    }
  }
  network_interface { # блок настройки сетевого интерфейса
    subnet_id = yandex_vpc_subnet.hl-subnet-1.id # указание сети для подлючения
    nat       = true # Включен NAT
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}" # пользователь и путь до открытого ключа для подключения по SSH
  }
  connection { #Блок настройки подключения
    type        = "ssh" # Тип подключения 
    user        = "ubuntu" # пользователь
    private_key = file("~/.ssh/id_ed25519") # путь до закрытого ключа
    host        = yandex_compute_instance.HL-1.network_interface.0.nat_ip_address # адрес для подключения
  }
}
```
- Добавлен раздел с настройками сетей
```
resource "yandex_vpc_network" "network1" { # Выбор ресурса, его порядковый номер
name = "hl-network-1" # указание отображаемого названия сети
}

resource "yandex_vpc_subnet" "hl-subnet-1" { # создание подсети 
network_id = "${yandex_vpc_network.network1.id}" # указание в какой сети создавать подсеть
v4_cidr_blocks = ["192.168.100.0/24"] # параметры адресации
zone           = var.zone
}
```
- Добавлен раздел выходных данных
```
output "internal_ip_address_HL-1" { # вывод внутреннего IP
  value = yandex_compute_instance.HL-1.network_interface.0.ip_address
}

output "external_ip_address_HL-1" { # вывод внешнего IP
  value = yandex_compute_instance.HL-1.network_interface.0.nat_ip_address
}
```
## Наполенение списка переменных variables.tf 
```
variable "cloud_id" {
  type = string
  default = "b1gr5j6ccsmb4re54g72"
}
variable "folder_id" {
  type = string
  default = "b1ghmcb9f5i5ciub7m84"
}
variable "yc_token" {
  type = string
  default = "token_data"
}
variable "image_id" {
  type = string
  default = "fd85hkli5dp6as39ali4"
}
variable "service_account_key_file" {
  type = string
  default = "key.json"
}
variable "zone" {
  type = string
  default = "ru-central1-a"
}
```

## Результаты
- Результат выполенение terraform init в terrafrom_init.txt
- Результат выполенения terraform plan в terraform_plan.txt
- Результат выполенения terraform apply в terraform_apply.txt
