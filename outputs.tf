output "agent_security_group_id" {
  value = "${aws_security_group.agent.id}"
}

output "agent_security_group_name" {
  value = "${aws_security_group.agent.name}"
}
