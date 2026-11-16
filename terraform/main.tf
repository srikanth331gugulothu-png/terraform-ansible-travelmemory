terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }

  }
}



data "aws_caller_identity" "current" {}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_user_arn" {
  description = "Authenticated AWS identity"
  value       = data.aws_caller_identity.current.arn
}