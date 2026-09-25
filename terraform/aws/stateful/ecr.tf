resource "aws_ecr_repository" "frontend" {

  name = "${local.resource_name}-frontend"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags

}

resource "aws_ecr_repository" "backend" {

  name = "${local.resource_name}-backend"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags

}


###### Lifecycle policy (delete old images) for backeknd and frontend
###### in case if oneday we decide to do versioning of images
###### and we do not want explose ECR

resource "aws_ecr_lifecycle_policy" "frontend" {

  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1

        description = "Keep last 10 images"

        selection = {

          tagStatus = "any"

          countType = "imageCountMoreThan"

          countNumber = 10

        }

        action = {

          type = "expire"

        }

      }

    ]

  })

}

resource "aws_ecr_lifecycle_policy" "backend" {

  repository = aws_ecr_repository.backend.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1

        description = "Keep last 10 images"

        selection = {

          tagStatus = "any"

          countType = "imageCountMoreThan"

          countNumber = 10

        }

        action = {

          type = "expire"

        }

      }

    ]

  })

}