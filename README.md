# ECS Threat Composer Deployment

<!-- Project badges -->
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![AWS ECS](https://img.shields.io/badge/AWS-ECS-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue)

This project is a deployment of a containerised web application (AWS Threat Composer). It involves comtainerising the app using Docker; building the infrastructure in Terraform and automating deployments using GitHub Actions. The website has been secured and is accessible via a custom domain over HTTPS. The result is an end to end, production style setup that is deployable to AWS.

## Repository Structure
```text
ECS PROJECT
├── .github/
│   └── workflows/
│       ├── build-push.yml
│       └── deploy.yml      
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
-	VPC with public and private subnets across 2 availability zones (AZs)
-	NAT Gateway in 2 AZ's providing outbound internet access from private subnets
-	Application Load Balancer (ALB) in public subnets to distribute imcoming traffic
-	ECS Fargate service running tasks in private subnets
-	ACM certificate for HTTPS
-	Route 53 + Cloudflare for DNS
-	Terraform state backend (S3 for state storage)
-	GitHub Actions for CI/CD using OIDC

## Overview

The project followed a staged procedure, moving from local validation to automated deployment.

### Prerequisites
- AWS account
- Domain managed via Route 53 and/or Cloudflare
- Docker
- Terraform
- GitHub repository

## Application and Local Validation

I first had to clone the existing Threat Composer application repository.

Local set up:
```bash
yarn install
yarn build
yarn global add serve
serve -s build
```

Enter into your browser:
```text
http://localhost:3000
```
Local Health Check:
```bash
curl -f http://localhost:3000/health.json
```

## Terraform (Infrastructure)
Terraform provisions the AWS infrastructure using a modular setup.

#### Request flow
1. User types `tm.mraheem.co.uk` into the browser.
2. Route 53 resolves the domain and returns the ALB DNS name.
3. For HTTP requests, ALB redirects them to HTTPS.
4. For HTTPS, the ALB performs a TLS handshake using the ACM certificate. The request is then forwarded to the target group, which has the task IPs.
5. ECS manages tasks running in private subnets. Container receives traffic on port 8080 and logs are sent to CloudWatch.

#### Networking
- Creates a VPC with 2 Availability Zones (AZ). Each AZ has its own public and private subnet
- NATGW's are situated in public subnets providing the private subnets with outbound access. Public subnets route to an Internet Gateway.

#### Application Load Balancer
- Creates an internet facing ALB with:
  - HTTP listener that redirects to HTTPS
  - HTTPS listener that forwards to our target group
- Creates a Route 53 alias A record pointing the subdomain to the ALB.

#### SSL/TLS Cert (HTTPS)
- Requests an ACM certificate using DNS validation.
- Creates the CNAME validation records in our Route 53 hosted zone and completes certificate validation.

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

All workflows run from this repo using GitHub Actions and authenticate to AWS using GitHub OIDC. 

### Push to ECR workflow:
- Trigger: push to `main` when `app/` or `Dockerfile` changes or manual run with confirmation.
- Action: Build Docker image and push to ECR.
- Tags: latest and the github SHA.

![Build and Push to ECR](images/build-push-ecr.png)

### Terraform Deploy workflow:
- Trigger: manual run with confirmation.
- Action: `terraform apply -auto-approve`.
- Verify: wait 60s then `curl -f https://tm.mrahaeem.co.uk/health.json` to run a health check.

![Terraform Deploy](images/terraform-deploy.png)

--- 

## Live Domain Page

![Domain Page](images/live-domain.png)

---

## Challenges and lessons learnt
Throughout this project, I faced several challenges, which helped me furthen my understanding. I also recognised the importance of commiting often and early to make safe, iterative changes and ease debugging. Some of the challenges included:
- Application not being accessible to the internet and the traffic not reaching the ALB.
- As a Mac user, I was implementing ARM 64 when I built the infrastructure via terraform. This resulted in very long build times when it came to building my pipelines.

