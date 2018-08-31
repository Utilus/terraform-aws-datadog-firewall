locals {
  resource_suffix = "${var.environment != "" ? "-${var.environment}" : ""}${var.project != "" ? "-${var.project}" : ""}"

  common_tags = {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  security_group_rule_limit = 50

  security_group_vpc = "${var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default.id}"
}

data "aws_vpc" "default" {
  default = true
}
