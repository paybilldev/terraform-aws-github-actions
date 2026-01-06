variable "github_user" {
  description = "GitHub user/organization that will access AWS via OIDC"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch name (e.g., main)"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub user/organization that has been generated"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "github-actions-role"
}

variable "policy_name" {
  description = "Name of the IAM policy for GitHub Actions"
  type        = string
  default     = "github-actions-policy"
}

variable "s3_buckets" {
  description = "List of S3 bucket ARNs the GitHub Actions role can access"
  type        = list(string)
  default     = ["*"] # Change to specific ARNs for least privilege
}

variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project"
}

variable "create_oidc_provider" {
  type    = bool
  default = true
}