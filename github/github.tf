terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.3.1"
    }
  }
}

data "github_user" "current" {
  username = ""
}

data "github_repository" "infra_hideyoshi_com" {
  full_name = "${var.github_owner}/${var.github_repository}"
}

resource "github_actions_environment_secret" "cluster_kubeconfig" {
  repository = data.github_repository.infra_hideyoshi_com.name
  environment = var.environment_name
  secret_name = "KUBECONFIG"
  plaintext_value = var.cluster_kubeconfig
}