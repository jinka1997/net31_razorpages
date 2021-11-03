resource "aws_ssm_parameter" "db_connection_string" {
  data_type = "text" 
  name      = "/${local.app_name}/connection/${local.environment}" 
  tags      = {} 
  tier      = "Standard" 
  type      = "SecureString"
  value     = "Server=${aws_rds_cluster.aurora_provisioned.endpoint};Port=${aws_rds_cluster.aurora_provisioned.port};User ID=${aws_rds_cluster.aurora_provisioned.master_username};Database=${aws_rds_cluster.aurora_provisioned.database_name};Password=${aws_rds_cluster.aurora_provisioned.master_password};"
}