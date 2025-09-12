# GitHub Actions OIDC Authentication with AWS

This repository demonstrates how to set up secure authentication between GitHub Actions and AWS using OpenID Connect (OIDC) instead of storing long-lived AWS access keys as secrets.

## Overview

This example uses **Terragrunt** to manage AWS infrastructure that enables GitHub Actions to authenticate with AWS using OIDC. The setup includes:

- **OIDC Provider**: Creates an AWS IAM OIDC identity provider for GitHub Actions
- **IAM Role**: Creates an IAM role with specific permissions for GitHub Actions workflows
- **ECR Permissions**: Configured for container registry operations

## Architecture

```
GitHub Actions → OIDC Provider → IAM Role → AWS Services
```

The setup consists of two main components:

1. **Global OIDC Provider** (`global/github-oidc/`): Creates the OIDC identity provider
2. **Backend IAM Role** (`backend/github-deploy-iam/`): Creates the IAM role with ECR permissions

## Project Structure

```
terragrunt/
└── live/
    ├── root.hcl                    # Root configuration with remote state
    └── us-west-2/
        ├── region.hcl              # Region-specific configuration
        └── dev/
            ├── env.hcl             # Environment-specific configuration
            ├── global/
            │   ├── app.hcl         # Global app configuration
            │   └── github-oidc/
            │       └── terragrunt.hcl  # OIDC provider setup
            └── backend/
                ├── app.hcl         # Backend app configuration
                └── github-deploy-iam/
                    └── terragrunt.hcl  # IAM role setup
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.50
- AWS CLI configured with appropriate permissions
- An S3 bucket named `tf-state` in `us-west-2` for remote state storage

## Configuration Details

### 1. OIDC Provider Configuration

**File**: `terragrunt/live/us-west-2/dev/global/github-oidc/terragrunt.hcl`

```hcl
terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-oidc-provider?version=6.2.1"
}

inputs = {
  url = "https://token.actions.githubusercontent.com"
  tags = local.all.common_tags
}
```

This creates an OIDC identity provider that trusts GitHub's token endpoint.

### 2. IAM Role Configuration

**File**: `terragrunt/live/us-west-2/dev/backend/github-deploy-iam/terragrunt.hcl`

Key features:
- **Role Name**: `dev-backend-github-actions`
- **OIDC Integration**: Enabled with GitHub OIDC provider
- **Trust Policy**: Allows authentication from specific GitHub repositories
- **ECR Permissions**: Full ECR access for container operations

#### Trust Policy
```hcl
oidc_wildcard_subjects = [
  "some_org_or_user/repo_name:*"
]
```

#### IAM Policy
The role includes permissions for:
- `ecr:GetAuthorizationToken` (required for all ECR operations)
- ECR repository operations (push, pull, delete images)
- Repository management (describe, list)

## Deployment

### 1. Deploy OIDC Provider

```bash
cd terragrunt/live/us-west-2/dev/global/github-oidc
terragrunt apply
```

### 2. Deploy IAM Role

```bash
cd terragrunt/live/us-west-2/dev/backend/github-deploy-iam
terragrunt apply
```

## GitHub Actions Workflow Example

Create a `.github/workflows/deploy.yml` file in your repository:

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]

permissions:
  id-token: write   # Required for OIDC
  contents: read    # Required for checkout

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::YOUR_ACCOUNT_ID:role/dev-backend-github-actions
          aws-region: us-west-2

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push Docker image
        run: |
          # Your build and push commands here
          echo "Building and pushing to ECR..."
```

## Security Considerations

### 1. Repository Restrictions

Update the `oidc_wildcard_subjects` in the IAM role configuration to restrict access to specific repositories:

```hcl
oidc_wildcard_subjects = [
  "your-org/your-repo:*",           # All branches
  "your-org/your-repo:ref:refs/heads/main",  # Only main branch
  "your-org/your-repo:environment:production"  # Only production environment
]
```

### 2. Environment-based Access

For production environments, consider using GitHub environments with protection rules:

```hcl
oidc_wildcard_subjects = [
  "your-org/your-repo:environment:production"
]
```

### 3. Least Privilege

The current configuration provides ECR access. Modify the IAM policy to include only the permissions your workflow actually needs.

## Customization

### Adding More AWS Services

To add permissions for other AWS services, modify the `source_inline_policy_documents` in the IAM role configuration:

```hcl
source_inline_policy_documents = [
  jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "s3:GetObject",           # Add S3 permissions
          "lambda:InvokeFunction"   # Add Lambda permissions
        ]
        Resource = "*"
      }
      # Add more statements as needed
    ]
  })
]
```

### Multiple Environments

To deploy to multiple environments, create additional environment directories:

```
terragrunt/live/us-west-2/
├── dev/
└── prod/
    └── backend/
        └── github-deploy-iam/
            └── terragrunt.hcl
```

## Troubleshooting

### Common Issues

1. **"No OpenIDConnect provider found"**
   - Ensure the OIDC provider is deployed before the IAM role
   - Check that the OIDC provider ARN is correctly referenced

2. **"Access denied" in GitHub Actions**
   - Verify the repository name in `oidc_wildcard_subjects` matches exactly
   - Check that the workflow has `id-token: write` permission

3. **"Invalid identity token"**
   - Ensure the GitHub Actions workflow is using the correct role ARN
   - Verify the AWS region matches the role's region

### Debugging

Enable debug logging in Terragrunt:

```bash
export TERRAGRUNT_LOG=debug
terragrunt apply
```

## Benefits of OIDC Authentication

- **No Long-lived Secrets**: Eliminates the need to store AWS access keys as GitHub secrets
- **Automatic Rotation**: Tokens are automatically rotated by AWS
- **Fine-grained Access**: Control access based on repository, branch, or environment
- **Audit Trail**: All authentication events are logged in CloudTrail
- **Reduced Risk**: No risk of accidentally exposing long-lived credentials

## References

- [AWS IAM OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Actions OIDC with AWS](https://docs.github.com/en/actions/deployment/security/hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Terraform AWS IAM Module](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest)
