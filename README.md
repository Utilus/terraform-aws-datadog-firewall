[![pipeline status](https://gitlab.com/utilus/open-source/terraform-aws-datadog-firewall-cicd/badges/master/pipeline.svg)](https://gitlab.com/utilus/open-source/terraform-aws-datadog-firewall-cicd/commits/master)

# terraform-aws-datadog-firewall

Terraform module to whitelist DataDog IPs in AWS security groups.

DataDog is a service that can be used for monitoring infrastructures and applications.
In most cases you will deploy a DataDog agent in your infrastructure in order to collect metrics, logs, events, etc.
To that end you will need to allow this agent to call home, and home is a very long list of IPs. 
In it's [documentation](https://docs.datadoghq.com/agent/network/), DataDog advises users to whitelist their domain in our firewalls.
However if that firewall is a AWS security group it won't accept a domain name as the target of a rule.

This terraform module tries to address the firewalling for DataDog agents by querying a REST API provided by DataDog that lists all it's IPs and then create security groups and rules that cover those IPs.
Every time terraform runs with this module in it's configuration, it will read the IPs from the REST API, generate a list of security group rules with those IPs and add those rules to specific security groups.

## Usage

Use this module to create security groups for the different types of traffic that DataDog expects.
Then configure the created security groups in other resources like `aws_instance` or `aws_launch_configuration`.
This module exports security groups both my name and id.


### Dependencies

This module makes use of a few command line tools to gather the DataDog IPs:
* curl
* jq

### Example

```hcl
provider "aws" {

}

module "datadog_firewall" {
  source = "https://github.com/Utilus/terraform-aws-datadog-firewall"
  
  project = "myProject"
  
  environment = "development"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  
  security_groups = [
    "${module.datadog_firewall.agent_security_group_name}",
    "${module.datadog_firewall.log_security_group_name}",
    "${module.datadog_firewall.process_security_group_name}",
    "${module.datadog_firewall.apm_security_group_name}",
  ]

  tags {
    Name = "HelloWorld"
  }
}
```

## CI/CD

This repository defines and trigger several CI/CD pipelines.

## Run CI builds locally
The pipeline jobs can be tested locally on the DEV environment using a script in `local/run-dev-job.sh`.

```bash
# validate configuration
env ENV_AWS_ACCESS_KEY_ID="..." \
    ENV_AWS_SECRET_ACCESS_KEY="..." \
    local/run-dev-job.sh build

# test configuration
env ENV_AWS_ACCESS_KEY_ID="..." \
    ENV_AWS_SECRET_ACCESS_KEY="..." \
    local/run-dev-job.sh test

# release
env ENV_AWS_ACCESS_KEY_ID="..." \
    ENV_AWS_SECRET_ACCESS_KEY="..." \
    local/run-dev-job.sh release
```
