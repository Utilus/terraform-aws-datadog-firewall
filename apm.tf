locals {
  apm_ips = "${compact(split(",", data.external.apm_ip_list.result.ips))}"
}

data "external" "apm_ip_list" {
  program = [
    "${path.module}/download-and-filter-ips.sh",
    "https://ip-ranges.datadoghq.com",
    "apm",
    "${local.security_group_rule_limit}"
  ]
}

resource "aws_security_group" "apm" {
  name        = "datadog-apm-ips"
  description = "Access to datadog apm IPs"

  tags = "${local.common_tags}"
}

resource "aws_security_group_rule" "apm_traffic_apm_https" {
  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.apm_ips}"]

  security_group_id = "${aws_security_group.apm.id}"
}
