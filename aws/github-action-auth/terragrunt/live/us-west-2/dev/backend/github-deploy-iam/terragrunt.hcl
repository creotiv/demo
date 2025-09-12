# Include all parent configurations
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "region" {
  path   = find_in_parent_folders("region.hcl")
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

include "app" {
  path   = find_in_parent_folders("app.hcl")
  expose = true
}

locals {
  # Create a merged configuration with all values
  all = {
    # From region
    region = include.region.locals.region
    # From env
    env = include.env.locals.env
    # From app
    app = include.app.locals.app

    # Final merged tags
    common_tags = merge(
      include.root.locals.common_tags,
      include.region.locals.common_tags,
      include.app.locals.common_tags,
      {
        Component = "iam"
      }
    )
  }
}

# Dependencies
dependency "ecr" {
  config_path = "../ecr-back"
}

dependency "github_oidc" {
  config_path = "../../global/github-oidc"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-role?version=6.2.1"
}

inputs = {
  name = "${local.all.env}-${local.all.app}-github-actions"

  enable_github_oidc      = true
  github_oidc_provider_arn = dependency.github_oidc.outputs.arn
  oidc_wildcard_subjects  = [
    "some_org_or_user/repo_name:*"
  ]

  create_inline_policy = true

  source_inline_policy_documents = [
   jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:DescribeRepositories",
            "ecr:DescribeImages",
            "ecr:BatchDeleteImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage"
          ]
          Resource = dependency.ecr.outputs.repository_arn
        }
      ]
    })
  ]

  tags = local.all.common_tags
}
