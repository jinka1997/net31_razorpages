resource "aws_cloudwatch_metric_alarm" "aurora_cpu_too_high" {
  actions_enabled           = true 
  alarm_actions             = [
    aws_sns_topic.notify.arn,
  ]
  alarm_name                = "${local.resource_name}-aurora-instance-High-CPU" 
  dimensions                = {
    "DBInstanceIdentifier" = aws_rds_cluster_instance.aurora_provisioned_instance.identifier
  } 
  evaluation_periods        = 1 
  insufficient_data_actions = [] 
  namespace                 = "AWS/RDS" 
  metric_name               = "CPUUtilization" 
  comparison_operator       = "GreaterThanOrEqualToThreshold" 
  statistic                 = "Average" 
  threshold                 = 80 
  ok_actions                = [] 
  period                    = 300
  tags                      = {} 
  treat_missing_data        = "missing"
}

resource "aws_cloudwatch_metric_alarm" "aurora_too_low_memory" {
  actions_enabled           = true
  alarm_actions             = [
    aws_sns_topic.notify.arn,
  ] 
  alarm_name                = "${local.resource_name}-aurora-instance-Low-FreeableMemory"
  comparison_operator       = "LessThanOrEqualToThreshold" 
  dimensions                = {
    "DBInstanceIdentifier" = aws_rds_cluster_instance.aurora_provisioned_instance.identifier
  } 
  evaluation_periods        = 1 
  insufficient_data_actions = [] 
  metric_name               = "FreeableMemory" 
  namespace                 = "AWS/RDS" 
  ok_actions                = [] 
  period                    = 300 
  statistic                 = "Average" 
  tags                      = {} 
  threshold                 = 1073741824 
}

