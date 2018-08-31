variable "project" {
  default = ""

  description = "Project name used to name resources and add tags where possible."
}

variable "environment" {
  default = ""

  description = "Environment name used to name resources and add tags where possible."
}

variable "vpc_id" {
  default = ""

  description = "The ID of the VPC where the security groups are created. If not specified then it defualts tot he default VPC."
}
