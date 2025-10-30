variable "environment_name" {
    type = string
}

variable "github_owner" {
    type = string
}

variable "github_repositories" {
    type = list(string)
}


variable "cluster_kubeconfig" {
    type = string
    sensitive = true  
}