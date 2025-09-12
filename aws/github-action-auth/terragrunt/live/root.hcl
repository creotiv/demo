remote_state {
  backend = "s3"
  config = {
    bucket         = "tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
  }
}

# Generate backend configuration for all modules
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}

locals {
  naming = {
    prefix = "demo"
    env    = "dev"
    region = "us-west-2"
  }
  
  common_tags = {
    Project   = "demo"
    ManagedBy = "terraform"
  }
}


