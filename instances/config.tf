### SET VARIABLES

variable "project_name" {
    type = string
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
}

variable "aws_main_instance_type" {
    type = string
}

variable "aws_worker_instance_type" {
    type = string
}

variable "aws_ami" {
    type = string
}

variable "aws_spot_price" {
    type = number
    default = 0
}

variable "ssh_public_key_main" {
    type = string
}

variable "ssh_public_key_ci_cd" {
    type = string
}