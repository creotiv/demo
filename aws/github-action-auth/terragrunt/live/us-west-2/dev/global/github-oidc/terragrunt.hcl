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
  all = {
    region = include.region.locals.region
    env    = include.env.locals.env
    app    = include.app.locals.app

    common_tags = merge(
      include.root.locals.common_tags,
      include.region.locals.common_tags,
      include.app.locals.common_tags,
      {
        Component = "iam-oidc"
      }
    )
  }
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-oidc-provider?version=6.2.1"
}

inputs = {
  // Default for GitHub
  url = "https://token.actions.githubusercontent.com"

  tags = local.all.common_tags
}


