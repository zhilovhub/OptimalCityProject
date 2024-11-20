locals {
  k8s-version = "1.27"
  zone = "ru-central1-b"
}

// Создание сервисного аккаунта для master node
resource "yandex_iam_service_account" "master_node_sa" {
  name = "master-node-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "master_editor" {
  folder_id = var.folder_id
  role               = "editor"
  member             = "serviceAccount:${yandex_iam_service_account.master_node_sa.id}"
}

// Создание сервисного аккаунта для worker node
resource "yandex_iam_service_account" "worker_node_sa" {
  name = "worker-node-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "worker_puller" {
  folder_id = var.folder_id
  role               = "container-registry.images.puller"
  member             = "serviceAccount:${yandex_iam_service_account.worker_node_sa.id}"
}

// Создание VPC для Kubernetes
resource "yandex_vpc_network" "default" {
  name = "network-for-k8s"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "default-b" {
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = local.zone
  network_id     = yandex_vpc_network.default.id
}

// Создание Kubernetes-кластера
resource "yandex_kubernetes_cluster" "zonal_cluster_resource_name" {
  name        = "k8s-cluster"

  network_id = yandex_vpc_network.default.id

  master {
    version = local.k8s-version
    zonal {
      zone = yandex_vpc_subnet.default-b.zone
      subnet_id = yandex_vpc_subnet.default-b.id
    }

    public_ip = true
  }

  service_account_id = yandex_iam_service_account.master_node_sa.id
  node_service_account_id = yandex_iam_service_account.worker_node_sa.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.master_editor,
    yandex_resourcemanager_folder_iam_member.worker_puller
  ]
}

// Создание группы узлов для Kubernetes-кластера
resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id  = yandex_kubernetes_cluster.zonal_cluster_resource_name.id
  name        = "k8s-node-group"
  version     = local.k8s-version

  instance_template {
    platform_id = "standard-v3"

    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.default-b.id]
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = local.zone
    }
  }

}
