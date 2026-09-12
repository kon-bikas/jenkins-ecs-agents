data "aws_iam_policy" "ecs_full_access" {
  name = "AmazonECS_FullAccess"
}

resource "aws_iam_role" "jenkins_controller_role" {
  name = "jenkins_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "JenkinsControllerEC2Role"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_policy_attach" {
  role       = aws_iam_role.jenkins_controller_role.name
  policy_arn = data.aws_iam_policy.ecs_full_access.arn
}

resource "aws_iam_instance_profile" "jenkins_role_profile" {
  name = "jenkins_profile"
  role = aws_iam_role.jenkins_controller_role.name
}


resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs_task_policy"
  description = "Policy for ECS tasks to be able to access ECR resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ECSJenkinsTaskRole"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}