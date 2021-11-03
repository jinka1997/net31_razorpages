locals {
  vpc_cidr_block             = "10.20.0.0/16" 
  subnet_public1a_cidr_block = "10.20.1.0/24" 
  subnet_public1c_cidr_block = "10.20.2.0/24" 
  subnet_private1a_cidr_block = "10.20.3.0/24" 
  subnet_private1c_cidr_block = "10.20.4.0/24" 
}
resource "aws_vpc" "vpc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "${local.vpc_cidr_block}"
  enable_dns_hostnames             = true 
  enable_dns_support               = true 
  tags                             = {
    "Name" = "${local.resource_name}"
  } 
}

resource "aws_internet_gateway" "gw" {
  tags     = {
      "Name" = "${local.resource_name}"
  }
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_subnet" "public1a" {
  availability_zone               = "ap-northeast-1a" 
  cidr_block                      = "${local.subnet_public1a_cidr_block}"
  tags                            = {
    "Name" = "${local.resource_name}-public-1a"
  } 
  vpc_id                          = aws_vpc.vpc.id
}

resource "aws_subnet" "public1c" {
  availability_zone               = "ap-northeast-1c" 
  cidr_block                      = "${local.subnet_public1c_cidr_block}"
  tags                            = {
    "Name" = "${local.resource_name}-public-1c"
  } 
  vpc_id                          = aws_vpc.vpc.id
}



resource "aws_subnet" "private1a" {
  availability_zone               = "ap-northeast-1a" 
  cidr_block                      = "${local.subnet_private1a_cidr_block}"
  tags                            = {
    "Name" = "${local.resource_name}-private-1a"
  } 
  vpc_id                          = aws_vpc.vpc.id
}

resource "aws_subnet" "private1c" {
  availability_zone               = "ap-northeast-1c" 
  cidr_block                      = "${local.subnet_private1c_cidr_block}"
  tags                            = {
    "Name" = "${local.resource_name}-private-1c"
  } 
  vpc_id                          = aws_vpc.vpc.id
}

resource "aws_eip" "nat_gateway" {
  tags                 = {
    "Name" = "${local.resource_name}-nat"
  }
  vpc                  = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id        = aws_eip.nat_gateway.id
  subnet_id            = aws_subnet.public1a.id
  tags                 = {
    "Name" = "${local.resource_name}"
  } 
}

resource "aws_route_table" "custom" {
  route            = [
    {
      carrier_gateway_id         = ""
      cidr_block                 = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = aws_internet_gateway.gw.id
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""          
    }
  ]
  tags             = {
    "Name" = "${local.resource_name}-for-public-subnet"
  }
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route_table" "main" {
  route            = [
    {
      carrier_gateway_id         = ""
      cidr_block                 = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = aws_nat_gateway.nat.id
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""      
    }
  ]
  tags             = {
    "Name" = "${local.resource_name}-for-private-subnet"
  }
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route_table_association" "public1a" {
  route_table_id = aws_route_table.custom.id
  subnet_id      = aws_subnet.public1a.id
}
resource "aws_route_table_association" "public1c" {
  route_table_id = aws_route_table.custom.id
  subnet_id      = aws_subnet.public1c.id
}


resource "aws_route_table_association" "private1a" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.private1a.id
}
resource "aws_route_table_association" "private1c" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.private1c.id
}
