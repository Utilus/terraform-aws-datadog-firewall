locals {
  logs_ips = "${compact(split(",", data.external.logs_ip_list.result.ips))}"
}

data "external" "logs_ip_list" {
  program = [
    "${path.module}/download-and-filter-ips.sh",
    "https://ip-ranges.datadoghq.com",
    "logs",
    "${local.security_group_rule_limit}"
  ]
}

resource "aws_security_group" "logs" {
  name        = "datadog-log-ips"
  description = "Access to datadog log IPs"

  tags = "${local.common_tags}"
}

resource "aws_security_group_rule" "logs_traffic_log_port" {
  type = "egress"

  protocol = "tcp"

  from_port = "10516"
  to_port   = "10516"

  cidr_blocks = ["${local.logs_ips}"]

  security_group_id = "${aws_security_group.logs.id}"
}
