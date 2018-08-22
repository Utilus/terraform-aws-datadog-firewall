output "agent_security_group_id" {
  value = "${aws_security_group.agent.id}"
}

output "agent_security_group_name" {
  value = "${aws_security_group.agent.name}"
}

output "log_security_group_id" {
  value = "${aws_security_group.log.id}"
}

output "log_security_group_name" {
  value = "${aws_security_group.log.name}"
}

output "process_security_group_id" {
  value = "${aws_security_group.process.id}"
}

output "process_security_group_name" {
  value = "${aws_security_group.process.name}"
}
