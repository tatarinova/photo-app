resource "aws_iam_role" "ec2_role" {

  name = "${local.resource_name}-ec2-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

  tags = local.common_tags

}

#### permissions to access S3

resource "aws_iam_role_policy_attachment" "s3_access" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

}


resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${local.resource_name}-instance-profile"

  role = aws_iam_role.ec2_role.name

  tags = local.common_tags

}


### permisions to download Docker images from ECR

resource "aws_iam_role_policy_attachment" "ecr_access" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}