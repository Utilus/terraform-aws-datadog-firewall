locals {
  agents_ips = "${compact(split(",", data.external.agent_ip_list.result.ips))}"
}

data "external" "agent_ip_list" {
  program = [
    "${path.module}/download-and-aggregate-ips.sh",  "https://ip-ranges.datadoghq.com", "agents", "${local.security_group_rule_limit}"
  ]
}

resource "aws_security_group" "agents" {
  name        = "datadog-agents-ips${local.resource_suffix}"
  description = "Access to datadog agent IPs"

  tags = "${merge(local.common_tags, map("Name", "datadog-agents-ips${local.resource_suffix}"))}"
}

resource "aws_security_group_rule" "agents_traffic_https" {
  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.agents_ips}"]

  security_group_id = "${aws_security_group.agents.id}"
}
