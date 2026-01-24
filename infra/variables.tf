variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "alt_name" {
  description = "specifies all subdomains"
  type        = string
}

variable "ecr_repo_url" {
  type = string
}


variable "image_tag" {
  type = string
}

variable "vpc_cidr" {
    description = "cidr block for vpc"
    type = string
}

variable "pubsubnet_a_cidr" {
    description = "The cidr for public subnet a"
    type = string
}

variable "pubsubnet_b_cidr" {
    description = "The cidr for public subnet b"
    type = string
}

variable "pvtsubnet_a_cidr" {
    description = "The cidr for private subnet a"
    type = string
}

variable "pvtsubnet_b_cidr" {
    description = "The cidr for private subnet b"
    type = string
}

variable "container_port" {
    description = "container port"
    type = string
}