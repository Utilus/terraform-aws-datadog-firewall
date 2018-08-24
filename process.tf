locals {
  process_ips_file = "tmp-process-ips.txt"

  process_ips = "${compact(split("\n", data.local_file.process_ips.content))}"
}

resource "null_resource" "extract_process_ip_list" {

  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "cat ${local.datadog_ip_ranges_file} | jq -r '.process .prefixes_ipv4[] | map(select(length > 0))' | shuf | head -n ${local.security_group_rule_limit} | tee ${local.process_ips_file}"
  }

  depends_on = [
    "null_resource.download_ip_list"
  ]

}

data "local_file" "process_ips" {

  filename   = "${local.process_ips_file}"

  depends_on = [
    "null_resource.extract_process_ip_list"
  ]

}

resource "aws_security_group" "process" {

  name = "datadog-process-ips-${local.resource_suffix}"

  description = "Access to datadog process IPs"

  tags = "${local.common_tags}"

  depends_on = [
    "data.local_file.process_ips"
  ]

}

resource "aws_security_group_rule" "process_traffic_https" {

  type = "egress"

  protocol = "tcp"

  from_port = "443"
  to_port   = "443"

  cidr_blocks = ["${local.process_ips}"]

  security_group_id = "${aws_security_group.process.id}"

}
