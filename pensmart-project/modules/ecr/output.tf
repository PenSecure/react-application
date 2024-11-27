output "repository_url" {
  value = { for repo in var.ecr_names : repo => aws_ecr_repository.main[repo].repository_url }
}

output "repository_arn" {
  value = { for repo in var.ecr_names : repo => aws_ecr_repository.main[repo].arn }
}