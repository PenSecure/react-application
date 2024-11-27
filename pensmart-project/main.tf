## Use aws_ssm_parameter to retrieve the VPC ID from Parameter Store
data "aws_ssm_parameter" "db_username" {
  name = "/pensmart/db_username"
}

## # This is using a getting a value in parameter store
data "aws_ssm_parameter" "db_password" {
  name = "/pensmart/db_password"
}

## # This is using a getting a value in parameter store
data "aws_ssm_parameter" "account_id" {
  name = "/pensmart/account_id"
}

## # This is using a getting a value in parameter store
data "aws_ecr_repository" "spring" {
  name = "spring"
depends_on = [module.ecr]
}

## # This is using a getting a value in parameter store
#data "aws_ecr_repository" "frontend" {
#  name = "frontend"
#  depends_on = [module.ecr]
#}


#######################################################################
#                                 VPC                                 #
#######################################################################
module "vpc" {
  source   = "./modules/vpc"
  az_count = var.az_count
  vpc_cidr = var.vpc_cidr
}

#######################################################################
#                                 ECR                                 #
#######################################################################
module "ecr" {
  source       = "./modules/ecr"
  ecr_names     = var.ecr_names
  force_delete = var.force_delete
}

#######################################################################
#                          cert manager                               #
#######################################################################
#module "cert_manager" {
#  source       = "./modules/acm"
#  domain_name  = var.domain_name
#  alb_dns_name = module.lb.alb_dns_name
#}

#######################################################################
#                               postgresql                                #
#######################################################################
module "postgresql" {
  source              = "./modules/postgresql"
  availability_zone   = module.vpc.availability_zone
  vpc_id              = module.vpc.vpc_id
  publicly_accessible = var.publicly_accessible
  port                = var.port
  deletion_protection = var.deletion_protection
  db_instance_class   = var.db_instance_class
  db_name             = var.db_name
  db_password         = data.aws_ssm_parameter.db_username.value
  db_username         = data.aws_ssm_parameter.db_password.value
  engine_version      = var.engine_version
  subnet_ids          = module.vpc.subnet_public_ids
  multi_az            = var.multi_az

  depends_on = [module.vpc]
}

#######################################################################
#                               lb                                    #
#######################################################################
module "lb" {
  source          = "./modules/lb"
  subnet_ids      = module.vpc.subnet_public_ids
  vpc_id          = module.vpc.vpc_id
  #certificate_arn = module.cert_manager.certificate_arn

  depends_on = [module.vpc]
}

#######################################################################
#                               ecs                                   #
#######################################################################
module "ecs" {
  source = "./modules/ecs"
  services = {
    "spring-service" = {
      service_name = "spring-service"
      image        = "${data.aws_ecr_repository.spring.repository_url}:latest"
      port         = 8080
      cpu          = 256
      memory       = 512
      environment = [
        {
          "name" : "DB_USERNAME",
          "value" : data.aws_ssm_parameter.db_username.value # This is using a value in parameter store
        },
        {
          "name" : "DB_URL",
          "value" :  "jdbc:postgresql://${module.postgresql.db_instance_endpoint}/postgres"
        },
        {
          "name" : "DB_PASSWORD",
          "value" : data.aws_ssm_parameter.db_password.value # This is using a value in parameter store
        },
        {
          "name" : "NODE_OPTIONS",
          "value" : "--openssl-legacy-provider"
        }        
      ]
      desired_count          = 1
      assign_public_ip       = true
      health_check_path      = "/login"
      path_patterns          = ["/login*"]
      max_capacity           = 5
      min_capacity           = 1
      scale_out_target_value = 75.0
      scale_in_target_value  = 25.0
    },
  }
  
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.subnet_public_ids
  alb_security_group_id      = module.lb.alb_security_groups_id
  alb_listener_arn           = module.lb.http
  enable_service_autoscaling = false

  depends_on = [module.lb, module.vpc, module.postgresql]
}
