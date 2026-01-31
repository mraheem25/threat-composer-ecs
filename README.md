# ECS Threat Composer Deployment

This project is a complete AWS deployment of a containerised web application. It focuses on building the infrastructure using Terraform, packaging the app with Docker and automating deployments using GitHub Actions. The result is a live, production style setup deployed to AWS and accessible through a custom domain over HTTPS.

## Project Structure
```text
./
├── .github/
│   └── workflows/
│       ├── build-push.yaml
│       └── deploy.yaml      
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

## Architecture

![architecture diagram](./images/ecs-architecture-diagram.png)

Key components:
-	VPC with public and private subnets across multiple AZs
-	Application Load Balancer (ALB) in public subnets
-	ECS Fargate service running tasks in private subnets
-	NAT Gateway for outbound internet access from private subnets
-	ACM certificate for HTTPS
-	Route 53 + Cloudflare for DNS
-	S3 remote Terraform state backend
-	GitHub Actions for CI/CD using OIDC

## Overview

The project was built incrementally, moving from local validation and moving to automated deployment.

### Prerequisites
- AWS account
- Terraform
- Docker
- GitHub repository
- Domain managed via Route 53 and/or Cloudflare

## Application and Local Validation

I first had to clone the existing Threat Composer application repository.

- Local set up:
```bash
yarn install
yarn build
yarn global add serve
serve -s build
```

Then in your browser run:
```text
http://localhost:3000
```
- Local Health Check:
After the local setup you can run a health check:
```bash
curl -f http://localhost:3000/health.json
```

## Terraform (Infrastructure)
Terraform provisions the AWS infrastructure in `infra/` using a modular setup.

#### Request flow
1. User enters `tm.mraheem.co.uk` into the browser.
2. Route 53 looks up the domain and returns the ALB DNS name.
3. If the request is HTTP, the ALB redirects it to HTTPS.
4. For HTTPS, the ALB performs the TLS handshake using the ACM cert then forwards the request to the target group which has the task IPs.
5. An ECS service manages tasks running in private subnets. The container receives traffic on port 8080 and logs are sent to CloudWatch.

#### Networking
- Creates a VPC with public and private subnets across 2 Availability Zones.
- Public subnets route to an Internet Gateway and private subnets use NAT Gateways for outbound access.

#### Load Balancing and DNS
- Creates an internet facing ALB with:
  - HTTP listener that redirects to HTTPS
  - HTTPS listener that forwards to the target group
- Creates a Route 53 alias A record pointing the subdomain to the ALB.

#### TLS (HTTPS)
- Requests an ACM certificate using DNS validation.
- Creates the validation records in Route 53 and completes certificate validation.

#### ECS
- Creates an ECS cluster.
- Creates the task definition.
- Creates an ECS service that manages tasks in private subnets.
- Tasks only accept inbound traffic from the ALB on port 8080.

#### IAM
- Creates the ECS task execution role used by tasks at runtime.

#### ECR
- Reads an existing ECR repository for the deployment

## CI/CD Workflows (GitHub Actions)

All workflows run from this repo using GitHub Actions and authenticate to AWS using GitHub OIDC. Terraform workflows run from the `infra/` directory and require manual confirmation.

### Push to ECR workflow:
- Trigger: push to `main` when `app/` or `Dockerfile` changes or manual run with confirmation.
- Action: build Docker image and push to ECR.
- Tags: latest and the github SHA.

![Build and Push to ECR](images/build-push-ecr.png)

### Terraform Apply workflow:
- Trigger: manual run with confirmation.
- Action: `terraform apply -auto-approve`.
- Verify: wait 60s then `curl -f https://tm.mrahaeem.co.uk/health.json` to run a health check on the deployed application.

![Terraform Deploy](images/terraform-deploy.png)
