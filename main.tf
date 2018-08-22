locals {
  security_group_rule_limit = 50

  datadog_ip_ranges_file = "tmp-datadog-ip-ranges.json"
}

resource "null_resource" "download_ip_list" {

  triggers {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "curl https://ip-ranges.datadoghq.com -o ${local.datadog_ip_ranges_file}"
  }

}
