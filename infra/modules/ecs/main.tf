resource "aws_ecs_cluster" "threatmod-ecs-cluster" {
    name = "threatmod-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "cw-log-group" {
  name              = var.log_group_name
  retention_in_days = var.log_days
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "threatmod-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.task_definition_cpu
  memory = var.task_definition_memory

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "threatmodel"
      image     = "${var.ecr_repo_url}:${var.image_tag}"
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cw-log-group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.awslogs_stream_prefix
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_security_group" "threatmod-ecs-sg" {
  name   = "threatmod-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow ALB to reach ECS tasks on 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "main" {
    name            = "threatcomp-service"
    cluster         = aws_ecs_cluster.threatmod-ecs-cluster.id
    task_definition = aws_ecs_task_definition.ecs-task-definition.arn
    desired_count   = 2
    launch_type     = "FARGATE"

    network_configuration {
    security_groups  = [aws_security_group.threatmod-ecs-sg.id]
    subnets          = [var.pvtsubnet_a_id, var.pvtsubnet_b_id]
    assign_public_ip = false
    }
 
    load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "threatmodel"
    container_port   = var.container_port
    }
}