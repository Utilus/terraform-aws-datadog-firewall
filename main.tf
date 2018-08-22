locals {
  security_group_rule_limit = 25

  datadog_ip_ranges_file = "tmp-datadog-ip-ranges.json"

  agent_ips_file = "tmp-agent-ips.txt"

  agent_ips = "${compact(split("\n", data.local_file.agent_ips.content))}"
}

resource "null_resource" "download_ip_list" {

  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "curl https://ip-ranges.datadoghq.com -o ${local.datadog_ip_ranges_file}"
  }

}

resource "null_resource" "extract_agents_ip_list" {

  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "cat ${local.datadog_ip_ranges_file} | jq -r '.agents .prefixes_ipv4[]' | head -n ${local.security_group_rule_limit} > ${local.agent_ips_file}"
  }

  depends_on = [
    "null_resource.download_ip_list"
  ]

}

data "local_file" "agent_ips" {

  filename   = "${local.agent_ips_file}"

  depends_on = [
    "null_resource.extract_agents_ip_list"
  ]

}


resource "aws_security_group" "agent" {

  name = "datadog-agent-ips"

  description = "Access to datadog agent IPs"

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

resource "aws_security_group_rule" "agent_traffic_ntp" {

  type = "egress"

  protocol = "udp"

  from_port = "123"
  to_port   = "123"

  cidr_blocks = ["${local.agent_ips}"]

  security_group_id = "${aws_security_group.agent.id}"

}
