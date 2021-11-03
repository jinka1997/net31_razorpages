resource "aws_security_group" "alb" {
  description = "alb-${local.resource_name}" 
  egress      = [
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
  ] 
  ingress     = [
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
  ]  
  name        = "alb-${local.resource_name}"
  tags        = {} 
  vpc_id      = aws_vpc.vpc.id

}

resource "aws_security_group" "ecs_service" {
  description = "ecs-service-${local.resource_name}"
  egress      = [
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress     = [
    {
      cidr_blocks      = []
      description      = "alb"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [
        aws_security_group.alb.id
      ]
      self             = false
      to_port          = 80
    },
  ]
  name        = "ecs-service-${local.resource_name}" 
  tags        = {} 
  vpc_id      = aws_vpc.vpc.id
  timeouts {}
}

resource "aws_security_group" "bastion" {
  description            = "bastion-${local.resource_name}"
  egress                 = [
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress                = [
    {
      cidr_blocks      = [
        "${var.myhome_ip_address}",
      ]
      description      = "myhome"
      from_port        = 3389
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3389
    },
  ]
  name                   = "bastion-${local.resource_name}"
  revoke_rules_on_delete = false
  tags                   = {}
  vpc_id                 = aws_vpc.vpc.id
}

resource "aws_security_group" "db" {
  description = "db-${local.resource_name}"
  egress      = [
    {
      cidr_blocks      = [
        "0.0.0.0/0"
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress     = [
    {
      cidr_blocks      = []
      description      = "bastion,ecs-service"
      from_port        = 5432
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [
        aws_security_group.ecs_service.id,
        aws_security_group.bastion.id
      ]
      self             = false
      to_port          = 5432
    },
  ]
  tags        = {}
  name        = "db-${local.resource_name}"
  vpc_id      = aws_vpc.vpc.id
}