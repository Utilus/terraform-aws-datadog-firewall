locals {
  logs_ips = "${sort(compact(split(",", data.external.logs_ip_list.result.ips)))}"
}

data "external" "logs_ip_list" {
  program = [
    "${path.module}/download-and-aggregate-ips.sh", "https://ip-ranges.datadoghq.com", "logs", "${local.security_group_rule_limit}"
  ]
}

resource "aws_security_group" "logs" {
  name        = "datadog-logs-ips${local.resource_suffix}"
  description = "Access to datadog log IPs"

  vpc_id = "${local.security_group_vpc}"

  tags = "${merge(local.common_tags, map("Name", "datadog-logs-ips${local.resource_suffix}"))}"
}

resource "aws_security_group_rule" "logs_traffic_log_port" {
  type = "egress"

  protocol = "tcp"

  from_port = "10516"
  to_port   = "10516"

  cidr_blocks = ["${local.logs_ips}"]

  security_group_id = "${aws_security_group.logs.id}"
}
