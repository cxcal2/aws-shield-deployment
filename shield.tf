# Shield Advanced subscription (organization-wide)
resource "aws_shield_protection_group" "org_protection" {
  protection_group_id = "org-wide-protection"
  aggregation         = "MAX"
  pattern             = "ALL"
}

# Shield protection for ALB
resource "aws_shield_protection" "alb" {
  name         = "alb-shield-protection"
  resource_arn = aws_lb.main.arn
}

# Shield protection for EIPs (if needed)
resource "aws_shield_protection" "eip" {
  count        = length(aws_instance.web)
  name         = "eip-shield-protection-${count.index}"
  resource_arn = "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:eip-allocation/${aws_eip.web[count.index].id}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
