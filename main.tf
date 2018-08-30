locals {
  resource_suffix = "${var.environment != "" ? "-${var.environment}" : ""}${var.project != "" ? "-${var.project}" : ""}"

  common_tags = {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  security_group_rule_limit = 50
}
