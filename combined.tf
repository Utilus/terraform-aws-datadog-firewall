locals {
  https_rules = [
    "${local.agents_ips}",
    "${local.process_ips}",
    "${local.apm_ips}",
  ]

  unique_https_rules = ["${sort(distinct(local.https_rules))}"]

  security_group_count = "${(length(local.unique_https_rules) + length(local.logs_ips)) / local.security_group_rule_limit + 1}"

  https_cidrs_lists = ["${chunklist(local.unique_https_rules, local.security_group_rule_limit)}"]
}

resource "aws_security_group" "combined" {
  count = "${local.security_group_count}"

  name        = "datadog-combined-${count.index + 1}${local.resource_suffix}"
  description = "Access to datadog process IPs for agents, process, logs and APM - Number ${count.index + 1}"

  vpc_id = "${local.security_group_vpc}"

  tags = "${merge(local.common_tags, map("Name", "datadog-combined-${count.index + 1}${local.resource_suffix}"))}"

}

resource "aws_security_group_rule" "datadog_traffic_https" {
  count = "${length(local.https_cidrs_lists)}"

  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.https_cidrs_lists[count.index]}"]

  security_group_id = "${element(aws_security_group.combined.*.id, count.index)}"
}

resource "aws_security_group_rule" "datadog_traffic_logs_port" {
  type = "egress"

  protocol = "tcp"

  from_port = "10516"
  to_port   = "10516"

  cidr_blocks = ["${local.logs_ips}"]

  security_group_id = "${element(aws_security_group.combined.*.id, length(aws_security_group.combined.*.id) -1)}"
}
