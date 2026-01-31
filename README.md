# ECS Threat Composer Deployment

This project is a complete AWS deployment of a containerised web application. It focuses on building the infrastructure using Terraform, packaging the app with Docker and automating deployments using GitHub Actions. The result is a live, production style setup deployed to AWS and accessible through a custom domain over HTTPS.

## Project Structure
```text
./
├── .github/
│   └── workflows/
│       ├── build-and-push.yaml
│       ├── terraform-deploy.yaml
│       
│       
├── app/
├── infra/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── modules/
│       ├── acm/
│       ├── alb/
│       ├── ecr/
│       ├── ecs/
│       ├── iam/
│       └── vpc/
└── Dockerfile
```
