output "agent_security_group_id" {
  description = "ID of the security group for agent traffic"

  value = "${aws_security_group.agent.id}"
}

output "agent_security_group_name" {
  description = "Name of the security group for agent traffic"

  value = "${aws_security_group.agent.name}"
}

output "log_security_group_id" {
  description = "ID of the security group for log traffic"

  value = "${aws_security_group.log.id}"
}

output "log_security_group_name" {
  description = "Name of the security group for log traffic"

  value = "${aws_security_group.log.name}"
}

output "process_security_group_id" {
  description = "ID of the security group for process traffic"

  value = "${aws_security_group.process.id}"
}

output "process_security_group_name" {
  description = "Name of the security group for process traffic"

  value = "${aws_security_group.process.name}"
}
