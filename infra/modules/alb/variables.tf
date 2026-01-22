variable "subnet_a_id" {
    description = "id of public subnet a"
    type = string
}

variable "subnet_b_id" {
    description = "id of public subnet b"
    type = string
}

variable "vpc_id" {
    description = "vpc id"
    type = string
}

variable "health_check_path" {
    description = "path for the health check for the target group"
    type = string
    default = "/health"
}

variable "health_matcher" {
    description = "matcher for the health check"
    type = number
    default = 200
}

variable "cert_arn" {
  description = "arn of the certficate"
  type = string
}

variable "ssl_policy" {
  description = "ssl policy"
  type = string
  default = "ELBSecurityPolicy-2016-08"
}

variable "zone_name" {
    description = "zone name"
    type = string
    default = "mraheem.co.uk"
}

variable "record_name" {
    description = "record name"
    type = string
    default = "tm"
}

variable "record_type" {
    description = "record type"
    type = string
    default = "A"
}