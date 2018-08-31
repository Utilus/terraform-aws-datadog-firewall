locals {
  apm_ips = "${compact(split(",", data.external.apm_ip_list.result.ips))}"
}

# APM has a small ammount of IPs so there is no need to aggregate them
data "external" "apm_ip_list" {
  program = [
    "${path.module}/download-ips.sh", "https://ip-ranges.datadoghq.com", "apm", "${local.security_group_rule_limit}"
  ]
}

resource "aws_security_group" "apm" {
  name        = "datadog-apm-ip${local.resource_suffix}"
  description = "Access to datadog apm IPs"

  vpc_id = "${local.security_group_vpc}"

  tags = "${merge(local.common_tags, map("Name", "datadog-apm-ips${local.resource_suffix}"))}"
}

resource "aws_security_group_rule" "apm_traffic_apm_https" {
  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.apm_ips}"]

  security_group_id = "${aws_security_group.apm.id}"
}
