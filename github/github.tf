terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.3.1"
    }
  }
}


data "github_repository" "repos" {
  for_each = toset(var.github_repositories)
  full_name = "${var.github_owner}/${each.value}"
}

resource "github_actions_organization_secret" "cluster_kubeconfig" {
  visibility = "selected"
  selected_repository_ids = [for repo in data.github_repository.repos : repo.repo_id]
  secret_name = "PORTFOLIO_KUBECONFIG"
  plaintext_value = chomp(var.cluster_kubeconfig)
}

resource "github_actions_organization_secret" "gpg_public_key" {
  visibility = "selected"
  selected_repository_ids = [for repo in data.github_repository.repos : repo.repo_id]
  secret_name = "PORTFOLIO_GPG_PUBLIC_KEY"
  plaintext_value = chomp(var.gpg_public_key_encryption)
}