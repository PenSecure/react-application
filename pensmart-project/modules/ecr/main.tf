resource "aws_ecr_repository" "main" {
  for_each             = toset(var.ecr_names)
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name      = "${terraform.workspace}-${each.value}"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}


