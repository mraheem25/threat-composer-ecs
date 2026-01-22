output "ecr_repo_url" {
  value = data.aws_ecr_repository.threatmodel.repository_url
}