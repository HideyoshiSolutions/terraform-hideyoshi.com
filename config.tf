### SET VARIABLES

variable "environment_name" {
    type = string
}

variable "project_name" {
    type = string
    default = "hideyoshi-portifolio"
}

variable "project_domain" {
    type = string
}

variable "k3s_token" {
    type = string
}

variable "number_of_workers" {
    type = number
    default = 2
}

variable "aws_region" {
    type = string
    default = "sa-east-1"
}

variable "aws_access" {
    type = string
}

variable "aws_secret" {
    type = string
}

variable "cloudflare_api_token" {
    type = string
}

variable "cloudflare_zone_id" {
    type = string
}

variable "ssh_public_key_main" {
    type = string
}

variable "ssh_public_key_ci_cd" {
    type = string
}