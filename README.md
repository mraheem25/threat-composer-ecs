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

## Procedure to reproduce

The project was built incrementally, moving from local validation and moving to automated deployment.

### Prerequisites
- AWS account
- Terraform
- Docker
- GitHub repository
- Domain managed via Route 53 and/or Cloudflare

### 1. Application and Local Validation
- Cloned existing Threat Composer application repository.

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

### 2. Containerisation
- Created a multi-stage Dockerfile inside the app.

- Built the image locally using:
```bash
docker built -t <image name> ./app
```

- Ran the container locally, mapping the container's port 80 to port 8080 on the host:
``` bash
docker run -p 8080:80 <image name>
```
- Verified container is running using curl:
``` bash
cult http://localhost:8080
```
- Image is ready to be pushed to ECR. 

### 3. Image Registry | AWS ECR
- Created an AWS ECR repository.

- Confirmed AWS credentials were configued:
``` bash
aws sts get-caller-identity
```
- Authenticated Docker to AWS ECR:
``` bash
aws ecr get-login-password --region <YOUR-REGION> \
| docker login --username AWS --password-stdin \
<YOUR AWS-ID>.dkr.ecr.<YOUR-REGION>.amazonaws.com
```

- Tagged image locally:
``` bash
docker tag <IMAGE-NAME:latest> \
<YOU-AWS-ID>.dkr.ecr.<YOUR-REGION>.amazonaws.com/<IMAGE-NAME>
```

- Pushed the image to ECR Repository:
``` bash
docker push \
<AWS-ID>.dkr.ecr.<YOUR-REGION>.amazonaws.com/<IMAGE-NAME>
```

### 4. ClickOps | Manual AWS Setup
- The main parts of the infrastructure were first created manually using the AWS console in order to understand how the services fit together.

- Created:
  - ECS Cluster (fargate).
  - Task definitions using the ECR Image.
  - Application Load Balancer.
  - Security Groups.
  - DNS Records.
  - ACM Certificate for HTTPS.

Once the application was reachable via HTTPS, all manual resources were deleted.

### 5. IaC | Terraform
I created the the setup using modular Terraform.

- Iniitialised Terraform in the directory:
```bash
terraform init
```

- Iteretively planned and applied infrastructure while building modules:
``` bash
terraform plan
terraform apply
```

- Verified infrastructure using the ALB DNS with HTTPS endpoint:
```bash
curl <ALB DNS>
curl https://<DOMAIN>
curl https://<DOMAIN>/health
```

- Destroyed infrastructure at the end:
``` bash
terraform destroy
```

### 6. CI/CD Automation
Implemented Github Actions for the pipelines.

### Build and Push

![architecture diagram](./images/build-cicd.png)

### Deploy and Post Health
![architecture diagram](./images/terraform-cicd.png)

![architecture diagram](./images/healthcheck-cicd.png)



