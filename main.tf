#############################################################################
## OIDC Provider for GitHub Actions
#############################################################################
resource "aws_iam_openid_connect_provider" "github_actions" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
}


#############################################################################
## Trust Policy
#############################################################################
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_user}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

#############################################################################
## IAM Role
#############################################################################
resource "aws_iam_role" "github_actions_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  description        = "Role for GitHub Actions via OIDC"
}

#############################################################################
## IAM Policy
#############################################################################
data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = var.s3_buckets
  }
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = var.policy_name
  description = "Policy for GitHub Actions tasks"
  policy      = data.aws_iam_policy_document.github_actions_permissions.json
}

#############################################################################
## Role + Policy Attachment
#############################################################################
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

resource "aws_ssm_parameter" "github_user" {
  name  = "/${var.namespace}/${var.environment}/github_user"
  type  = "SecureString"
  value = var.github_user
}

resource "aws_ssm_parameter" "github_token" {
  name  = "/${var.namespace}/${var.environment}/github_token"
  type  = "SecureString"
  value = var.github_token
}

resource "aws_ssm_parameter" "github_repo" {
  name  = "/${var.namespace}/${var.environment}/github_saas_repo"
  type  = "SecureString"
  value = var.github_repo
}

resource "aws_ssm_parameter" "github_branch" {
  name  = "/${var.namespace}/${var.environment}/github_branch"
  type  = "SecureString"
  value = var.github_branch
}
