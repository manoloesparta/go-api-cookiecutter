resource "aws_ecr_repository" "images_repo" {
  name = "app-api-${var.environment}"
}

resource "aws_s3_bucket" "files_bucket" {
  bucket = "app-files-${var.environment}"

  tags = {
    Name = "files-files-${var.environment}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_policy" "bucket_access_policy" {
  name = "app-bucket-access-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = [
          "${aws_s3_bucket.files_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "app_role" {
  name = "app-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "build.apprunner.amazonaws.com",
            "tasks.apprunner.amazonaws.com",
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bucket_policy_attachment" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.bucket_access_policy.arn
}

resource "aws_apprunner_service" "app" {
  service_name = "app-api-${var.environment}"

  health_check_configuration {
    path     = "/v1/healthcheck"
    protocol = "HTTP"
    interval = 20
  }

  instance_configuration {
    cpu               = "0.25 vCPU"
    memory            = "0.5 GB"
    instance_role_arn = aws_iam_role.app_role.arn
  }

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_role.arn
    }

    image_repository {
      image_configuration {
        port = "3000"
        runtime_environment_variables = {
          "APP_BUCKET" = aws_s3_bucket.files_bucket.id,
          "APP_DB_URL" = var.db_url
          "APP_ENV"    = var.environment
        }
      }
      image_identifier      = "${aws_ecr_repository.app_repo.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "apps-api"
  }
}

# resource "aws_apprunner_custom_domain_association" "api_subdomain" {
#   domain_name = var.environment == "prod" ? "api.domain.com" : "${var.environment}.api.domain.com"
#   service_arn = aws_apprunner_service.app.arn
# }


resource "aws_iam_policy" "repo_pull_policy" {
  name = "repo-app-runner-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_policy_attachment" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.repo_pull_policy.arn
}

resource "aws_apprunner_deployment" "deployment" {
  service_arn = aws_apprunner_service.app.arn
}
