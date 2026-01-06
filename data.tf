data "aws_caller_identity" "this" {}

data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_oidc_provider ? 0 : 1
  arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

data "tls_certificate" "oidc_thumbprint" {
  url = "https://token.actions.githubusercontent.com"
}
