locals {
  ConnectionArn        = "arn:aws:codestar-connections:ap-northeast-1:${data.aws_caller_identity.self.account_id}:connection/58a5410e-2665-4a5f-b3e3-301f0014f1a7"
  FullRepositoryId     = "jinka1997/net31_razorpages"
  RepositoryLocation   = "https://github.com/jinka1997/net31_razorpages.git"

  DockerFilePath       = "src/SampleWeb/SampleWeb/Dockerfile"
  BuildResultPath      = "src/SampleWeb"
  ImageDefFileName     = "imagedefinitions.json"
}

resource "aws_codepipeline" "pipeline" {
  name     = "${local.resource_name}" 
  role_arn = aws_iam_role.code_pipeline.arn
  tags     = {} 
  # TODO
  
  artifact_store {
    location = aws_s3_bucket.pipeline_artifact_store.bucket
    type     = "S3" 
  }
  
  stage {
    name = "Source" 
    action {
      category         = "Source"
      configuration    = {
        "BranchName"           = "master"
        "ConnectionArn"        = "${local.ConnectionArn}"
        "FullRepositoryId"     = "${local.FullRepositoryId}"
        "OutputArtifactFormat" = "CODE_ZIP"
      }
      input_artifacts  = []
      name             = "Source"
      namespace        = "SourceVariables"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection" 
      region           = "ap-northeast-1" 
      run_order        = 1 
      version          = "1" 
    }
  }
  stage {
    name = "Build"
    action {
      category         = "Build"
      configuration    = {
        "ProjectName" = aws_codebuild_project.build.name
      } 
      input_artifacts  = [
        "SourceArtifact",
      ]
      name             = "Build"
      namespace        = "BuildVariables"
      output_artifacts = [
        "BuildArtifact",
      ] 
      owner            = "AWS" 
      provider         = "CodeBuild"
      region           = "ap-northeast-1" 
      run_order        = 1 
      version          = "1" 
    }
  }
  stage {
    name = "Deploy" 
    action {
      category         = "Deploy"
      configuration    = {
        "ClusterName" = aws_ecs_cluster.cluster.name
        "FileName"    = "${local.ImageDefFileName}"
        "ServiceName" = aws_ecs_service.service.name
      }
      input_artifacts  = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      namespace        = "DeployVariables"
      output_artifacts = [] 
      owner            = "AWS"
      provider         = "ECS"
      region           = "ap-northeast-1"
      run_order        = 1 
      version          = "1"
    }
  }
}
resource "aws_codebuild_project" "build" {
  badge_enabled          = true
  build_timeout          = 60
  encryption_key         = "arn:aws:kms:ap-northeast-1:${data.aws_caller_identity.self.account_id}:alias/aws/s3"
  name                   = "${local.resource_name}"
  queued_timeout         = 480
  service_role           = aws_iam_role.code_build.arn
  tags                   = {} 
  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }
  cache {
    modes = [] 
    type  = "NO_CACHE" 
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0" 
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true 
    type                        = "LINUX_CONTAINER" 
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
  source {
    buildspec           = <<-EOT
        version: 0.2
        env:
          variables:
            DOCKERFILE_PATH: "${local.DockerFilePath}"
        phases:
          pre_build:
            commands:
              - echo Logging in to Amazon ECR...
              - aws --version
              - aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com
              - REPOSITORY_URI=${aws_ecr_repository.container_repository.repository_url}
              - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
              - IMAGE_TAG=$${COMMIT_HASH:=latest}
          build:
            commands:
              - echo Build started on `date`
              - echo Building the Docker image...
              - docker build -t $REPOSITORY_URI:latest -f $DOCKERFILE_PATH "${local.BuildResultPath}"
              - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
          post_build:
            commands:
              - echo Build completed on `date`
              - echo Pushing the Docker images...
              - docker push $REPOSITORY_URI:latest
              - docker push $REPOSITORY_URI:$IMAGE_TAG
              - echo Writing image definitions file...
              - printf '[{"name":"${local.app_name}","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > ${local.ImageDefFileName}
        artifacts:
            files: ${local.ImageDefFileName}
    EOT
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "${local.RepositoryLocation}"
    report_build_status = false
    type                = "GITHUB"
    git_submodules_config {
      fetch_submodules = false
    }
  }
}