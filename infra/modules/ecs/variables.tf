variable "log_group_name" {
  description = "group name for cloudwatch"
  type = string
  default = "ecs-logs"
}

variable "log_days" {
  description = "retention in days for cloudwatch logs"
  type = number
  default = 7
}


variable "task_definition_cpu" {
    description = "cpu required for the task definition"
    type = number
    default = 256 
}

variable "task_definition_memory" {
    description = "memory required for the task definitions"
    type = number
    default = 512
}

variable "ecr_repo_url" {
  type = string
  #default = "668383290434.dkr.ecr.eu-west-2.amazonaws.com/threatmodel"
}


variable "image_tag" {
  type = string
  #default = "sha256:e35970e6983407eb1c37b8c717f46a6a7a3c45ba0326b214389ec00f68cbd2e6"
}


variable "ecs_task_execution_role_arn" {
  type = string
}

variable "container_port" {
    description = "Ports for the container and app"
    type = number
    default = 80
}

variable "aws_region" {
  description = "cloudwatch region"
  type = string
  default = "eu-west-2"
}

variable "awslogs_stream_prefix" {
  description = "logstream prefix"
  type        = string
  default     = "ecs"
}

variable "vpc_id" {
    description = "id for the vpc"
    type = string
}

variable "alb_sg_id" {
  description = "id of the alb sg"
  type = string
}


variable "pvtsubnet_a_id" {
    description = "id of first private subnet"
    type = string
}

variable "pvtsubnet_b_id" {
    description = "id of the second priavte subnet"
    type = string
}

variable "target_group_arn" {
    description = "arn of the target group to reference for the load balancer in ecs service"
    type = string
}