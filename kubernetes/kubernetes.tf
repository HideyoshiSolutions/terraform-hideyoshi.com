terraform {
  required_providers {
    yoshik3s = {
      source  = "HideyoshiNakazone/yoshik3s"
      version = "0.1.2"
    }
  }
}


# Cluster Configuration

resource "yoshik3s_cluster" "main_cluster" {
  name        = "main-cluster"
  token       = var.cluster_token
  k3s_version = "v1.30.2+k3s2"
}


resource "yoshik3s_master_node" "master_node" {
  cluster = {
    token       = yoshik3s_cluster.main_cluster.token
    k3s_version = yoshik3s_cluster.main_cluster.k3s_version
  }
  
  count = length(var.cluster_main_node)

  node_connection = {
    host        = var.cluster_main_node[count.index].host
    port        = var.cluster_main_node[count.index].port
    user        = var.cluster_main_node[count.index].user
    private_key = var.cluster_main_node[count.index].private_key
  }

  node_options = [
    "--disable traefik",
    "--node-label node_type=master",
    "--tls-san ${var.cluster_domain}"
  ]
}


resource "yoshik3s_worker_node" "worker_node" {
  master_server_address = var.master_server_address

  cluster = {
    token       = yoshik3s_cluster.main_cluster.token
    k3s_version = yoshik3s_cluster.main_cluster.k3s_version
  }

  count = length(var.cluster_worker_node)

  node_connection = {
    host        = var.cluster_worker_node[count.index].host
    port        = var.cluster_worker_node[count.index].port
    user        = var.cluster_worker_node[count.index].user
    private_key = var.cluster_worker_node[count.index].private_key
  }

  node_options = [
    "--node-label node_type=worker",
  ]
}
