### PROVIDERS

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
    yoshik3s = {
      source = "HideyoshiNakazone/yoshik3s"
      version = "1.1.2"
    }
    github = {
      source = "integrations/github"
      version = "6.3.1"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access
  secret_key = var.aws_secret
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "yoshik3s" {
  # No configuration needed
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}


### MODULES

module "bucket" {
  source = "./bucket"
  providers = {
    aws.main = aws
  }
  project_domain = var.project_domain
  project_name   = var.project_name
}

module "instances" {
  source = "./instances"
  providers = {
    aws.main = aws
  }
  project_domain       = var.project_domain
  project_name         = var.project_name
  k3s_token            = var.k3s_token
  number_of_workers    = var.number_of_workers
  aws_region           = var.aws_region
  ssh_public_key_main  = var.ssh_public_key_main
  ssh_public_key_ci_cd = var.ssh_public_key_ci_cd
  aws_instance_type    = var.aws_instance_type
  aws_ami              = var.aws_ami
  aws_spot_price       = var.aws_spot_price 
}

module "dns" {
  source = "./dns"
  providers = {
    cloudflare = cloudflare
  }
  public_ip          = module.instances.pool_master_public_ip
  environment_name   = var.environment_name
  cloudflare_zone_id = var.cloudflare_zone_id
}

module "kubernetes" {
  source = "./kubernetes"
  providers = {
    yoshik3s = yoshik3s
  }
  cluster_token = var.k3s_token
  cluster_domain = var.project_domain
  master_server_address = module.instances.pool_master_public_ip
  cluster_main_node = module.instances.pool_master_instance
  cluster_worker_node = module.instances.pool_worker_instances
}

module "github" {
  source = "./github"
  providers = {
    github = github
  }
  environment_name = var.environment_name
  github_owner = var.github_owner
  github_repository = var.github_repository
  cluster_kubeconfig = module.kubernetes.cluster_kubeconfig
}


output "cluster_kubeconfig" {
  value = module.kubernetes.cluster_kubeconfig
  sensitive = true  
}