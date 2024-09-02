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

variable "aws_instance_type" {
    type = string
    default = "t4g.micro"
}

variable "aws_ami" {
    type = string
    default = "ami-06a17a87e19be286a"
}

variable "ssh_public_key_main" {
    type = string
}

variable "ssh_public_key_ci_cd" {
    type = string
}