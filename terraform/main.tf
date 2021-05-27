provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "rails-app-runner-playin"
      Owner = "Desmond"
    }
  }
}

resource "aws_ecr_repository" "rails-app-runner-playin" {
  name = "rails-app-runner-playin"
  # Prolly should do something about retention?
}

data "aws_iam_role" "apprunner" {
  name = "AppRunnerECRAccessRole"
}

resource "aws_apprunner_service" "rails-app-runner-playin" {
  service_name = "rails-app-runner-playin"

  source_configuration {
    authentication_configuration {
      access_role_arn = data.aws_iam_role.apprunner.arn
    }

    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier = "${aws_ecr_repository.rails-app-runner-playin.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }
}