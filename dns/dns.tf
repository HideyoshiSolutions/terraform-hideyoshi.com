terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}


variable "public_ip" {
    type = string
}

variable "environment_name" {
    type = string
}

variable "cloudflare_zone_id" {
    type = string
}


resource "cloudflare_record" "default" {
    zone_id = var.cloudflare_zone_id

    name = var.environment_name == "prod" ? "@" : "staging"
    content = var.public_ip
    type = "A"
    ttl = 3600
    proxied = false
}


resource "cloudflare_record" "api" {
    zone_id = var.cloudflare_zone_id

    name = var.environment_name == "prod" ? "api" : "api.staging"
    content = var.public_ip
    type = "A"
    ttl = 3600
    proxied = false
}