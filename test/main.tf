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
