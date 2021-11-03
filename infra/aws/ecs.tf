resource "aws_ecs_cluster" "cluster" {
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]
  name               = "${local.environment}"
  tags               = {}
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_service" "service" {
  cluster                            = aws_ecs_cluster.cluster.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 0
  launch_type                        = "FARGATE"
  name                               = "${local.resource_name}"
  platform_version                   = "LATEST"
  scheduling_strategy                = "REPLICA"
  tags                               = {}
  task_definition                    = "${aws_ecs_task_definition.task_definition.id}:${aws_ecs_task_definition.task_definition.revision}"
  wait_for_steady_state              = false
  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }
  deployment_controller {
    type = "ECS"
  }
  load_balancer {
    container_name   = "${local.app_name}"
    container_port   = 80
    target_group_arn = aws_lb_target_group.to_ecs_service.id
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = [
      aws_security_group.ecs_service.id,
    ] 
    subnets          = [
      aws_subnet.private1a.id ,
      aws_subnet.private1c.id,
    ]
  }
  depends_on = [
    aws_ecs_task_definition.task_definition
  ]
  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}


resource "aws_ecs_task_definition" "task_definition" {
  container_definitions    = jsonencode(
      [
        {
          cpu              = 0
          environment      = []
          essential        = true
          image            = "${aws_ecr_repository.container_repository.repository_url}:latest"
          logConfiguration = {
            logDriver = "awslogs"
            options   = {
              awslogs-group         = aws_cloudwatch_log_group.ecs_task.name
              awslogs-region        = "ap-northeast-1"
              awslogs-stream-prefix = "ecs"
            }
          }
          mountPoints      = []
          name             = local.app_name
          portMappings     = [
            {
              containerPort = 80
              hostPort      = 80
              protocol      = "tcp"
            },
          ]
          secrets          = [
            {
              name      = "ConnectionStrings__SampleWebContext"
              valueFrom = aws_ssm_parameter.db_connection_string.name
            },
          ]
          environment      = [
            {
              name      = "ASPNETCORE_ENVIRONMENT"
              value     = "Production"
            }
          ]
          volumesFrom      = []
        },
      ]
  )
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.execute_ecs_task.arn
  family                   = local.resource_name
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ] 
  tags                     = {}
  task_role_arn            = aws_iam_role.ecs_task.arn
}
