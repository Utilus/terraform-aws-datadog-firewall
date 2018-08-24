provider "aws" {
  region = "eu-west-1"
  profile = "nlo-gateway-dev-env"
}

module "datadog_firewall" {
  source = "../"
}

output "agent_security_group_id" {
  value = "${module.datadog_firewall.agent_security_group_id}"
}

output "agent_security_group_name" {
  value = "${module.datadog_firewall.agent_security_group_name}"
}

output "log_security_group_id" {
  value = "${module.datadog_firewall.log_security_group_id}"
}

output "log_security_group_name" {
  value = "${module.datadog_firewall.log_security_group_name}"
}

output "process_security_group_id" {
  value = "${module.datadog_firewall.process_security_group_id}"
}

output "process_security_group_name" {
  value = "${module.datadog_firewall.process_security_group_name}"
}

output "apm_security_group_id" {
  value = "${module.datadog_firewall.apm_security_group_id}"
}

output "apm_security_group_name" {
  value = "${module.datadog_firewall.apm_security_group_name}"
}
