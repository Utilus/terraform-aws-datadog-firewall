locals {
  process_ips = "${compact(split(",", data.external.process_ip_list.result.ips))}"
}

data "external" "process_ip_list" {
  program = [
    "${path.module}/download-and-filter-ips.sh",
    "https://ip-ranges.datadoghq.com",
    "process",
    "${local.security_group_rule_limit}"
  ]
}

resource "aws_security_group" "process" {
  name        = "datadog-process-ips-${local.resource_suffix}"
  description = "Access to datadog process IPs"

  tags = "${local.common_tags}"
}

resource "aws_security_group_rule" "process_traffic_https" {
  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.process_ips}"]

  security_group_id = "${aws_security_group.process.id}"
}
