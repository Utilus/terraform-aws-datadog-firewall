locals {
  apm_ips_file = "tmp-apm-ips.txt"

  apm_ips = "${compact(split("\n", data.local_file.apm_ips.content))}"
}

resource "null_resource" "extract_apm_ip_list" {

  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "cat ${local.datadog_ip_ranges_file} | jq -r '.apm .prefixes_ipv4[]' | shuf | head -n ${local.security_group_rule_limit} | tee ${local.apm_ips_file}"
  }

  depends_on = [
    "null_resource.download_ip_list"
  ]

}

data "local_file" "apm_ips" {

  filename   = "${local.agent_ips_file}"

  depends_on = [
    "null_resource.extract_apm_ip_list"
  ]

}

resource "aws_security_group" "apm" {

  name = "datadog-apm-ips"

  description = "Access to datadog apm IPs"

  tags = "${local.common_tags}"

  depends_on = [
    "data.local_file.apm_ips"
  ]

}

resource "aws_security_group_rule" "apm_traffic_apm_https" {

  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.apm_ips}"]

  security_group_id = "${aws_security_group.apm.id}"

}
