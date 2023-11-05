data "yandex_compute_image" "my_image" {
  family = var.instance_family_image
}


# Provider
provider "yandex" {
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.zone[0]
  # token     = var.yandex_cloud_token
  service_account_key_file = "/Users/qalab/sf-diplom/key/mmonk33.json"
}

# Service accounts
# Создание сервисного аккаунта в яндекс облаке для кластера srv ноды
resource "yandex_iam_service_account" "sf-mmonk33" {
  name = "sf-mmonk33"
}

# Назначаем права созданного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "sf-mmonk33-admin" {
  folder_id = var.yandex_folder_id
  role = "admin"
  member = "serviceAccount:${yandex_iam_service_account.sf-mmonk33.id}"
  depends_on = [
    yandex_iam_service_account.sf-mmonk33,
  ]
}

# Создаем ключи доступа Static Access Keys
resource "yandex_iam_service_account_static_access_key" "static-access-key" {
  service_account_id = yandex_iam_service_account.sf-mmonk33.id
  depends_on = [
    yandex_iam_service_account.sf-mmonk33,
  ]
}

# Compute instance for service
# Создаём ВМ - srv сервисную ноду, с которой будет просиходить развёртывание кластера k8s, мониторинг, логирование и процессы CI/CD
resource "yandex_compute_instance" "srv" { 
  name     = "srv"
  hostname = "srv"

  resources {
    cores  = 4
    memory = 12
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      size     = 30
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat       = true
  }

# SSH ключ для доступа к ВМ - нодам. Ключи создаём без пароля, Terraform не умеет работать с парольными ключами.
# Ключ в данном случае подбираем уже готовый с нашего ПК по адресу: /home/mikhail/.ssh/
  metadata = {
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
    serial-port-enable=1    
  }

}