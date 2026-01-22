module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  pubsubnet_a_cidr = var.pubsubnet_a_cidr
  pubsubnet_b_cidr = var.pubsubnet_b_cidr
  pvtsubnet_a_cidr = var.pvtsubnet_a_cidr
  pvtsubnet_b_cidr = var.pvtsubnet_b_cidr
}

module "iam" {
  source = "./modules/iam"
}

module "ecs" {
  source = "./modules/ecs"
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id    = module.vpc.vpc_id
  alb_sg_id = module.alb.alb_sg_id
  pvtsubnet_a_id = module.vpc.pvtsubnet_a_id
  pvtsubnet_b_id = module.vpc.pvtsubnet_b_id
  target_group_arn  = module.alb.target_group_arn
  image_tag = var.image_tag
  ecr_repo_url = var.ecr_repo_url
}

module "alb" {
  source = "./modules/alb"
  subnet_a_id = module.vpc.pubsubnet_a_id
  subnet_b_id = module.vpc.pubsubnet_b_id
  cert_arn = module.acm.acm_certificate_arn
  vpc_id     = module.vpc.vpc_id
}

module "acm" {
  source = "./modules/acm"
  domain_name = var.domain_name
  alt_name = var.alt_name
}

module "ecr" {
  source = "./modules/ecr"
}
