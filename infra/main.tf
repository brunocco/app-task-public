provider "aws" {
  region = "us-east-1"
}

# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "app_task" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-app-task"
  }
}

# -------------------------------
# Subnets Públicas
# -------------------------------
resource "aws_subnet" "pub_1a" {
  vpc_id                  = aws_vpc.app_task.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "subnet-pub-app-task-1a" }
}

resource "aws_subnet" "pub_1b" {
  vpc_id                  = aws_vpc.app_task.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "subnet-pub-app-task-1b" }
}

# -------------------------------
# Subnets Privadas
# -------------------------------
resource "aws_subnet" "priv_1c" {
  vpc_id                  = aws_vpc.app_task.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags                    = { Name = "subnet-priv-app-task-1c" }
}

resource "aws_subnet" "priv_1d" {
  vpc_id                  = aws_vpc.app_task.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags                    = { Name = "subnet-priv-app-task-1d" }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_task.id
  tags   = { Name = "igw-app-task" }
}

# -------------------------------
# NAT Gateways
# -------------------------------
resource "aws_eip" "nat_1a" {
  domain = "vpc"
}

resource "aws_eip" "nat_1b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.pub_1a.id
  tags          = { Name = "app-task-nat-gat-1a" }
}

resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.nat_1b.id
  subnet_id     = aws_subnet.pub_1b.id
  tags          = { Name = "app-task-nat-gat-1b" }
}

# -------------------------------
# Route Tables
# -------------------------------
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.app_task.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "rt-pub-app-task" }
}

resource "aws_route_table_association" "pub_1a" {
  subnet_id      = aws_subnet.pub_1a.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub_1b" {
  subnet_id      = aws_subnet.pub_1b.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table" "priv_1c" {
  vpc_id = aws_vpc.app_task.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }
  tags = { Name = "rt-priv-app-task-1c" }
}

resource "aws_route_table_association" "priv_1c_assoc" {
  subnet_id      = aws_subnet.priv_1c.id
  route_table_id = aws_route_table.priv_1c.id
}

resource "aws_route_table" "priv_1d" {
  vpc_id = aws_vpc.app_task.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1b.id
  }
  tags = { Name = "rt-priv-app-task-1d" }
}

resource "aws_route_table_association" "priv_1d_assoc" {
  subnet_id      = aws_subnet.priv_1d.id
  route_table_id = aws_route_table.priv_1d.id
}

# -------------------------------
# ECS Cluster
# -------------------------------
resource "aws_ecs_cluster" "app_task" {
  name = "app-task-cluster"
}

# -------------------------------
# Security Groups
# -------------------------------
resource "aws_security_group" "alb" {
  name        = "app-task-alb"
  description = "SG para o ALB"
  vpc_id      = aws_vpc.app_task.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_backend" {
  name        = "app-task-ecs-backend"
  description = "SG para ECS Backend"
  vpc_id      = aws_vpc.app_task.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_frontend" {
  name        = "app-task-ecs-frontend"
  description = "SG para ECS Frontend"
  vpc_id      = aws_vpc.app_task.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "app-task-rds"
  description = "SG para RDS Postgres"
  vpc_id      = aws_vpc.app_task.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# Application Load Balancer
# -------------------------------
resource "aws_lb" "app_task_alb" {
  name               = "app-task-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.pub_1a.id,
    aws_subnet.pub_1b.id
  ]

  tags = { Name = "app-task-alb" }
}

# -------------------------------
# Target Groups
# -------------------------------
resource "aws_lb_target_group" "backend_tg" {
  name        = "app-task-backend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_task.id
  target_type = "ip"

  health_check {
    path                = "/tasks"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "app-task-backend-tg" }
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "app-task-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_task.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "app-task-frontend-tg" }
}

# -------------------------------
# Listener HTTP
# -------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_task_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/tasks*"]
    }
  }
}

# -------------------------------
# RDS PostgreSQL
# -------------------------------
resource "aws_db_subnet_group" "app_task" {
  name       = "db-subnet-group-app-task"
  subnet_ids = [aws_subnet.priv_1c.id, aws_subnet.priv_1d.id]

  tags = {
    Name = "db-subnet-group-app-task"
  }
}

resource "aws_db_instance" "app_task" {
  identifier             = "app-task-db"
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "tasksdb"
  username               = "postgres"
  password               = "postgres"
  port                   = 5432
  publicly_accessible    = false
  storage_type           = "gp2"
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.app_task.name
  skip_final_snapshot    = true

  tags = {
    Name = "rds-app-task"
  }
}

# -------------------------------
# IAM Role para ECS Task Execution
# -------------------------------
resource "aws_iam_role" "ecs_task_execution" {
  name = "app-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -------------------------------
# CloudWatch Log Groups
# -------------------------------
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/app-task/backend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/app-task/frontend"
  retention_in_days = 7
}

# -------------------------------
# ECS Task Definitions
# -------------------------------
resource "aws_ecs_task_definition" "backend" {
  family                   = "app-task-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "<SEU_ID_AWS_12DIGITOS>.dkr.ecr.us-east-1.amazonaws.com/app-task-backend:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_db_instance.app_task.address },
        { name = "DB_USER", value = "postgres" },
        { name = "DB_PASSWORD", value = "postgres" },
        { name = "DB_NAME", value = "tasksdb" },
        { name = "DB_PORT", value = "5432" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/app-task/backend"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "app-task-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "<SEU_ID_AWS_12DIGITOS>.dkr.ecr.us-east-1.amazonaws.com/app-task-frontend:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/app-task/frontend"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# -------------------------------
# ECS Services
# -------------------------------
resource "aws_ecs_service" "backend" {
  name            = "app-task-backend-svc"
  cluster         = aws_ecs_cluster.app_task.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.priv_1c.id, aws_subnet.priv_1d.id]
    security_groups  = [aws_security_group.ecs_backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "backend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "frontend" {
  name            = "app-task-frontend-svc"
  cluster         = aws_ecs_cluster.app_task.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.priv_1c.id, aws_subnet.priv_1d.id]
    security_groups  = [aws_security_group.ecs_frontend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

# -------------------------------
# Outputs
# -------------------------------
output "alb_dns_name" {
  value = aws_lb.app_task_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.app_task.endpoint
}

output "rds_port" {
  value = aws_db_instance.app_task.port
}
