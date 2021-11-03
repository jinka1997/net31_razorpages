resource "aws_cloudwatch_log_group" "rds_cluster_log" {
  name = "/aws/rds/cluster/${aws_rds_cluster.aurora_provisioned.cluster_identifier}/postgresql"

  tags = {}
  depends_on = [
    aws_rds_cluster.aurora_provisioned
  ]
}

resource "aws_cloudwatch_log_group" "ecs_task" {
  name              = "/ecs/${local.resource_name}"
  retention_in_days = 0
  tags              = {} 
}