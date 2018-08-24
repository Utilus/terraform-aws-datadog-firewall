locals {
  agent_ips = "${compact(split(",", data.external.agent_ip_list.result.ips))}"
}

data "external" "agent_ip_list" {
  program = [
    "${path.module}/download-and-filter-ips.sh",
    "https://ip-ranges.datadoghq.com",
    "agents",
    "${local.security_group_rule_limit}"
  ]
}

resource "aws_security_group" "agent" {
  name        = "datadog-agent-ips-${local.resource_suffix}"
  description = "Access to datadog agent IPs"

  tags = "${local.common_tags}"
}

resource "aws_security_group_rule" "agent_traffic_https" {
  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.agent_ips}"]

  security_group_id = "${aws_security_group.agent.id}"
}
