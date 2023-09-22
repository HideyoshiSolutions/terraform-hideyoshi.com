terraform {
  required_providers {
    godaddy = {
      source = "zaneatwork/godaddy"
      version = "1.9.10"
    }
  }
}


variable "public_ip" {
    type = string
}


resource "godaddy_domain_record" "default" {
    domain   = "hideyoshi.com.br"

    overwrite = false

    record {
        name = "staging	"
        type = "A"
        data = "${var.public_ip}"
        ttl = 600
        priority = 0
    }

    record {
        name = "api.staging	"
        type = "A"
        data = "${var.public_ip}"
        ttl = 600
        priority = 0
    }
}