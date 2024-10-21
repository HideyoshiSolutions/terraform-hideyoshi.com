variable "environment_name" {
    type = string
}

variable "github_owner" {
    type = string
    default = "HideyoshiSolutions"
}

variable "github_repository" {
    type = string
    default = "infra-hideyoshi.com"  
}


variable "cluster_kubeconfig" {
    type = string
    sensitive = true  
}