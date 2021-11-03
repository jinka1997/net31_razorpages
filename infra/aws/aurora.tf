resource "aws_rds_cluster" "aurora_provisioned" {
  backtrack_window                    = 0
  backup_retention_period             = 1
  cluster_identifier                  = "${local.resource_name}-cluster"
  database_name                       = replace("${local.resource_name}", "-", "_")
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  deletion_protection                 = false
  enable_global_write_forwarding      = false
  enabled_cloudwatch_logs_exports     = [
    "postgresql"
  ]
  engine                              = "aurora-postgresql"
  engine_version                      = "11.9"
  master_username                     = "postgres_${local.environment}"
  master_password                     = random_password.generated.result
  port                                = 5432
  skip_final_snapshot                 = true
  tags                                = {}
  vpc_security_group_ids              = [
    aws_security_group.db.id
  ]

  timeouts {}
}

resource "aws_rds_cluster_instance" "aurora_provisioned_instance" {
  identifier         = "${aws_rds_cluster.aurora_provisioned.cluster_identifier}-instance"
  cluster_identifier = aws_rds_cluster.aurora_provisioned.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora_provisioned.engine
  engine_version     = aws_rds_cluster.aurora_provisioned.engine_version
}
resource "aws_db_subnet_group" "db_subnet_group" {
  description = "${local.resource_name}"
  name        = "${local.resource_name}"
  subnet_ids  = [
    aws_subnet.private1a.id,
    aws_subnet.private1c.id,
  ] 
  tags        = {} 
}


resource "random_password" "generated" {
  length           = 16
  special          = false
  override_special = "!#$&"
}
