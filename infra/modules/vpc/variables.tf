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

variable "region" {
    description = "region"
    type = string
    default = "eu-west-2"
}

variable "az_1" {
    description = "availability zone 1"
    type = string
    default = "eu-west-2a"
}

variable "az_2" {
    description = "availability zone 2"
    type = string
    default = "eu-west-2b"
}

variable "rt_cidr" {
    description = "cidr for route table"
    type = string
    default = "0.0.0.0/0"
}
