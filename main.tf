### PROVIDERS

terraform {
  required_providers {
    godaddy = {
      source = "zaneatwork/godaddy"
      version = "1.9.10"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
    access_key = var.aws_access
    secret_key = var.aws_secret
}

provider "godaddy" {
    key = var.godaddy_key
    secret = var.godaddy_secret
}


### MODULES

module "bucket" {
    source = "./bucket"
    providers = {
        aws.main = aws
    }
    project_domain = var.project_domain
    project_name = var.project_name
}

module "instances" {
    source = "./instances"
    providers = {
        aws.main = aws
    }
    project_domain = var.project_domain
    project_name = var.project_name
    k3s_token = var.k3s_token
    number_of_workers = var.number_of_workers
    aws_region = var.aws_region
    ssh_public_key_main = var.ssh_public_key_main
    ssh_public_key_ci_cd = var.ssh_public_key_ci_cd
}

module "dns" {
    source = "./dns"
    providers = {
        godaddy = godaddy
    }
    public_ip = module.instances.pool_master_public_ip
    environment_name = var.environment_name
}