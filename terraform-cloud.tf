terraform {
    required_version = ">1.5"
    backend "remote" {
        hostname     = "app.terraform.io"
        organization = "HideyoshiNakazone"

        workspaces {
            prefix = "hideyoshi-portfolio-"
        }
    }
}