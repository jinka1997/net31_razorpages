resource "aws_iam_policy" "code_pipeline" {
  description = "${local.resource_name}"
  name        = "CodePipelineBasePolicy-${local.resource_name}"
  path        = "/service-role/" 
  policy      = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "codestar-connections:UseConnection",
                "s3:*",
                "ecs:*",
                "codebuild:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/*",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": "ecs-tasks.amazonaws.com"
                }
            }
        }
    ]
}  
  EOT
  tags        = {}  
}

resource "aws_iam_policy" "code_build" {
  description = "${local.resource_name}"
  name        = "CodeBuildBasePolicy-${local.resource_name}"
  path        = "/service-role/" 
  policy      = jsonencode(
      {
        Statement = [
          {
            Action   = [
              "ecr:GetRegistryPolicy",
              "ecr:DescribeRegistry",
              "ecr:GetAuthorizationToken",
              "ecr:DeleteRegistryPolicy",
              "ecr:PutRegistryPolicy",
              "ecr:PutReplicationConfiguration",
            ]
            Effect   = "Allow"
            Resource = "*"
            Sid      = "VisualEditor0"
          },
          {
            Action   = [
              "s3:GetBucketAcl",
              "logs:CreateLogGroup",
              "logs:PutLogEvents",
              "s3:PutObject",
              "s3:GetObject",
              "codebuild:CreateReportGroup",
              "codebuild:CreateReport",
              "logs:CreateLogStream",
              "codebuild:UpdateReport",
              "codebuild:BatchPutCodeCoverages",
              "ecr:*",
              "s3:GetBucketLocation",
              "codebuild:BatchPutTestCases",
              "s3:GetObjectVersion",
            ]
            Effect   = "Allow"
            Resource = [
              "arn:aws:logs:ap-northeast-1:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${local.resource_name}",
              "arn:aws:logs:ap-northeast-1:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${local.resource_name}:*",
              aws_ecr_repository.container_repository.arn,
              #"arn:aws:s3:::codepipeline-ap-northeast-1-*",
              "${aws_s3_bucket.pipeline_artifact_store.arn}/*",
              "arn:aws:codebuild:ap-northeast-1:${data.aws_caller_identity.self.account_id}:report-group/${local.resource_name}-*",
            ]
            Sid      = "VisualEditor1"
          },
        ]
        Version   = "2012-10-17"
      }
  ) 
  tags        = {}
}

resource "aws_iam_policy" "ecs_task" {
  description = "ecs-task-policy-${local.resource_name}"
  name        = "ecs-task-policy-${local.resource_name}"
  path        = "/" 
  policy      = jsonencode(
      {
        Statement = [            
          {
            Action   = [
              "ecr:GetRegistryPolicy",
              "ecr:DescribeRegistry",
              "ecr:GetAuthorizationToken",
              "ecr:DeleteRegistryPolicy",
              "ecr:PutRegistryPolicy",
              "ecr:PutReplicationConfiguration",
            ]
            Effect   = "Allow"
            Resource = "*"
            Sid      = "VisualEditor0"
          },
          {
            Action   = [
              "kms:Decrypt",
              "secretsmanager:GetSecretValue",
              "ssm:GetParameter",
            ]
            Effect   = "Allow"
            Resource = [
              "arn:aws:kms:*:${data.aws_caller_identity.self.account_id}:key/*",
              "arn:aws:secretsmanager:*:${data.aws_caller_identity.self.account_id}:secret:*",
              "arn:aws:ssm:*:${data.aws_caller_identity.self.account_id}:parameter/*",
            ]
            Sid      = "VisualEditor1"
          },
          {
            Action   = "ecr:*"
            Effect   = "Allow"
            Resource = aws_ecr_repository.container_repository.arn
            Sid      = "VisualEditor2"
          },
        ]
        Version   = "2012-10-17"
      }
  )
  tags        = {}
}

resource "aws_iam_policy" "execute_ecs_task" {
  description = "ecs-task-execution-policy-${local.resource_name}"
  name        = "ecs-task-execution-policy-${local.resource_name}"
  path        = "/" 
  policy      = jsonencode(
      {
        Statement = [
          {
            Action   = [
              "secretsmanager:GetSecretValue",
              "kms:Decrypt",
              "ssm:GetParameters",
            ]
            Effect   = "Allow"
            Resource = [
              "*"
            ]
            Sid      = "VisualEditor0"
          },
        ]
        Version   = "2012-10-17"
      }
  )
  tags      = {} 
}

