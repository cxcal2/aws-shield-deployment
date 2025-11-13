# Multi-account Shield setup using AWS Organizations

# Management account provider
provider "aws" {
  alias  = "management"
  region = "us-east-1"
}

# Member account providers
provider "aws" {
  alias  = "member1"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.member_account_1_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "member2"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.member_account_2_id}:role/OrganizationAccountAccessRole"
  }
}

# Enable Shield Advanced in management account
resource "aws_shield_subscription" "management" {
  provider                 = aws.management
  auto_renew               = "ENABLED"
  skip_destroy             = true
}

# Protection group for management account
resource "aws_shield_protection_group" "management" {
  provider            = aws.management
  protection_group_id = "management-account-protection"
  aggregation         = "MAX"
  pattern             = "ALL"
  
  depends_on = [aws_shield_subscription.management]
}

# Protection for member account 1
resource "aws_shield_protection_group" "member1" {
  provider            = aws.member1
  protection_group_id = "member1-account-protection"
  aggregation         = "MAX"
  pattern             = "ALL"
  
  depends_on = [aws_shield_subscription.management]
}

# Protection for member account 2
resource "aws_shield_protection_group" "member2" {
  provider            = aws.member2
  protection_group_id = "member2-account-protection"
  aggregation         = "MAX"
  pattern             = "ALL"
  
  depends_on = [aws_shield_subscription.management]
}

variable "member_account_1_id" {
  description = "AWS Account ID for member account 1"
  type        = string
}

variable "member_account_2_id" {
  description = "AWS Account ID for member account 2"
  type        = string
}
