locals {
  log_ips_file = "tmp-agent-ips.txt"

  log_ips = "${compact(split("\n", data.local_file.log_ips.content))}"
}

resource "null_resource" "extract_log_ip_list" {

  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "cat ${local.datadog_ip_ranges_file} | jq -r '.logs .prefixes_ipv4[]' | shuf | head -n ${local.security_group_rule_limit} | tee ${local.log_ips_file}"
  }

  depends_on = [
    "null_resource.download_ip_list"
  ]

}

data "local_file" "log_ips" {

  filename   = "${local.agent_ips_file}"

  depends_on = [
    "null_resource.extract_log_ip_list"
  ]

}

resource "aws_security_group" "log" {

  name = "datadog-log-ips"

  description = "Access to datadog log IPs"

  tags = "${local.common_tags}"

  depends_on = [
    "data.local_file.log_ips"
  ]

}

resource "aws_security_group_rule" "log_traffic_log_port" {

  type = "egress"

  protocol = "tcp"

  from_port = "10516"
  to_port   = "10516"

  cidr_blocks = ["${local.log_ips}"]

  security_group_id = "${aws_security_group.log.id}"

}
