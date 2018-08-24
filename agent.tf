locals {
  agent_ips_file = "tmp-agent-ips.txt"

  agent_ips = "${compact(split("\n", data.local_file.agent_ips.content))}"
}

resource "null_resource" "extract_agent_ip_list" {

  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "cat ${local.datadog_ip_ranges_file} | jq -r '.agents .prefixes_ipv4[] | map(select(length > 0))' | shuf | head -n ${local.security_group_rule_limit} | tee ${local.agent_ips_file}"
  }

  depends_on = [
    "null_resource.download_ip_list"
  ]

}

data "local_file" "agent_ips" {

  filename   = "${local.agent_ips_file}"

  depends_on = [
    "null_resource.extract_agent_ip_list"
  ]

}

resource "aws_security_group" "agent" {

  name = "datadog-agent-ips-${local.resource_suffix}"

  description = "Access to datadog agent IPs"

  tags = "${local.common_tags}"

  depends_on = [
    "data.local_file.agent_ips"
  ]

}

resource "aws_security_group_rule" "agent_traffic_https" {

  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.agent_ips}"]

  security_group_id = "${aws_security_group.agent.id}"

}
