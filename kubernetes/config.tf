variable "cluster_token" {
    type = string
    description = "cluster token"
    sensitive = true
}

variable "cluster_domain" {
    type = string
    description = "cluster domain"
}

variable "master_server_address" {
    type = string
    description = "master server address"  
}

variable "cluster_main_node" {
    type = list(object({
        host        = string
        port        = string
        user        = string
        private_key = string
    }))
    description = "map of objects - main cluster nodes - [host, port]"
}

variable "cluster_worker_node" {
    type = list(object({
        host        = string
        port        = string
        user        = string
        private_key = string
    }))
    description = "map of objects - worker cluster nodes - [host, port]"
}
