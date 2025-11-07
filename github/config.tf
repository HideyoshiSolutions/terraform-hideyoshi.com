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

variable "gpg_private_key_encryption" {
    type = string
    sensitive = true  
}