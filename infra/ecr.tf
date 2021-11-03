resource "aws_ecr_repository" "container_repository" {
  image_tag_mutability = "MUTABLE" 
  name                 = "${local.resource_name}"
  tags                 = {} 
  encryption_configuration {
    encryption_type = "AES256" 
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
