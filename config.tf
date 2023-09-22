### SET VARIABLES

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

variable "godaddy_key" {
    type = string
}

variable "godaddy_secret" {
    type = string 
}

variable "ssh_public_key_main" {
    type = string
}

variable "ssh_public_key_ci_cd" {
    type = string
}