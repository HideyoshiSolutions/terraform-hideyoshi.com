terraform {
    required_version = ">1.5"
    backend "remote" {
        organization = "HideyoshiNakazone"

        workspaces {
            prefix = "hideyoshi-portfolio-"
        }
    }
}