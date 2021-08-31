#ecs.tf


resource "aws_ecs_cluster" "servian-cluster" {
  name = "servian-cluster"

  tags = {
    Name = "servian-cluster"
    Resource = "servian"
  }
}

resource "aws_ecs_task_definition" "servian-task-definition" {
  family = "servian-task-definition"
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  network_mode = "host"

  container_definitions = <<TASK_DEFINITION
[
  {
    "container-name": "servian-container",
    "name": "app-container",
    "image": "${data.aws_ecr_repository.tech-challenge-app.repository_url}:latest",
    "essential": true,
    "cpu": 1024,
    "memoryReservation": 300,
    "compatibilities": [
      "EC2"
    ],
    "requiresCompatibilities": [
      "EC2"
    ],
    "environmentFiles": [
      {
        "value": "${aws_s3_bucket.servian-bucket.arn}/ecs.env",
        "type": "s3"
      }
    ],
    "portMappings": [
      {
        "hostPort": 3000,
        "protocol": "tcp",
        "containerPort": 3000
      },
      {
        "hostPort": 5432,
        "protocol": "tcp",
        "containerPort": 5432
      }
    ],
    "command": [
      "serve"
    ]
  }
]
TASK_DEFINITION

  tags = {
    Name = "servian-task-definition"
    Resource = "servian"
  }
}

resource "aws_ecs_service" "servian-service" {
  name = "servian-service"
  cluster = aws_ecs_cluster.servian-cluster.id
  task_definition = aws_ecs_task_definition.servian-task-definition.arn
  iam_role = data.aws_iam_role.AWSServiceRoleforECS.arn

  desired_count = 2
	launch_type = "EC2"
	enable_ecs_managed_tags = true
  propagate_tags = "TASK_DEFINITION"
  health_check_grace_period_seconds = 180

  load_balancer {
    target_group_arn = aws_lb_target_group.lb-target-group.arn
    container_name = "app-container"
    container_port = var.app_port
  }

  deployment_circuit_breaker {
    enable = true
    rollback = true
  }

	ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type = "spread"
	}

}
