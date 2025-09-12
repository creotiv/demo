locals {
  region      = "us-west-2"
  common_tags = {}
}

# Configure AWS provider in all modules to use the specified region
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.region}"
    }
  EOF
  # Use generate with no "if" so it applies to all child terragrunt modules
}
