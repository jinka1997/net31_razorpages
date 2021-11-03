resource "aws_iam_role" "code_pipeline" {
  assume_role_policy    = jsonencode(
      {
        Statement = [
          {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
              Service = "codepipeline.amazonaws.com"
            }
          },
        ]
        Version   = "2012-10-17"
      }
  )
  force_detach_policies = false
  managed_policy_arns   = [
    aws_iam_policy.code_pipeline.arn
  ]
  max_session_duration  = 3600
  name                  = "AWSCodePipelineServiceRole-${local.resource_name}"
  path                  = "/service-role/"
  tags                  = {}
  inline_policy {}
}


resource "aws_iam_role" "code_build" {
  assume_role_policy    = jsonencode(
      {
        Statement = [
          {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
              Service = "codebuild.amazonaws.com"
            }
          },
        ]
        Version   = "2012-10-17"
      }
  ) 
  managed_policy_arns   = [
    aws_iam_policy.code_build.arn,
  ]
  max_session_duration  = 3600
  name                  = "codebuild-${local.resource_name}-role" 
  path                  = "/service-role/" 
  tags                  = {} 
  inline_policy {}
}

resource "aws_iam_role" "ecs_task" {
  assume_role_policy    = jsonencode(
      {
        Statement = [
          {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
              Service = "ecs-tasks.amazonaws.com"
            }
            Sid       = ""
          },
        ]
        Version   = "2012-10-17"
      }
  )
  description           = "ecs-task-role-${local.resource_name}" 
  managed_policy_arns   = [
    #aws_iam_policy.ecs_task.arn,
  ]
  name                  = "ecs-task-role-${local.resource_name}" 
  path                  = "/" 
  tags                  = {} 
  inline_policy {}
}

resource "aws_iam_role" "execute_ecs_task" {
  assume_role_policy    = jsonencode(
      {
        Statement = [
          {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
              Service = "ecs-tasks.amazonaws.com"
            }
            Sid       = ""
          },
        ]
        Version   = "2008-10-17"
      }
  )
  managed_policy_arns   = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.execute_ecs_task.arn,
  ]
  name                  = "ecs-task-execution-role-${local.resource_name}"
  path                  = "/"
  tags                  = {} 
  inline_policy {}
}
