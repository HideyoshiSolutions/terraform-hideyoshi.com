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
    sensitive = true  
}

variable "number_of_workers" {
    type = number
    default = 2
}

variable "aws_region" {
    type = string
    default = "sa-east-1"
    sensitive = true  
}

variable "aws_access" {
    type = string
    sensitive = true  
}

variable "aws_secret" {
    type = string
    sensitive = true  
}

variable "aws_instance_type" {
    type = string
    default = "t4g.micro"
}

variable "aws_ami" {
    type = string
    default = "ami-06a17a87e19be286a"
}

variable "aws_spot_price" {
    type = number
    default = 0.0028
}

variable "cloudflare_api_token" {
    type = string
    sensitive = true  
}

variable "cloudflare_zone_id" {
    type = string
    sensitive = true  
}

variable "ssh_public_key_main" {
    type = string
    sensitive = true  
}

variable "ssh_public_key_ci_cd" {
    type = string
    sensitive = true  
}

variable "github_owner" {
    type = string
    default = "HideyoshiSolutions"
}

variable "github_token" {
    type = string
    sensitive = true  
}

variable "github_repository" {
    type = string
    default = "infra-hideyoshi.com"  
}