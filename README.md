[![pipeline status](https://gitlab.com/utilus/open-source/terraform-aws-datadog-firewall-cicd/badges/master/pipeline.svg)](https://gitlab.com/utilus/open-source/terraform-aws-datadog-firewall-cicd/commits/master)

# terraform-aws-datadog-firewall

Terraform module to whitelist DataDog IPs in AWS security groups.

DataDog is a service that can be used for monitoring infrastructures and applications.
In most cases you will deploy a DataDog agent in your infrastructure in order to collect metrics, logs, events, etc.
To that end you will need to allow this agent to call home, and home is a very long list of IPs. 
In it's [documentation](https://docs.datadoghq.com/agent/network/), DataDog advises users to whitelist their domain in our firewalls.
However if that firewall is a AWS security group it won't accept a domain name as the target of a rule.

Our first idea for this module was to try to pick some 50 IPs (50 is the default rule limit of an AWS Security Group) for each type of traffic and create security groups and rules that cover those IPs.
However, in discussions with DataDog support about this, we have learned that out of the 400+ IPs available not all will be accepting traffic and even those who are can be temporarily busy.
Therefore the risk of selecting 50 IPs for agent metrics, for example, and then have none of those being usable is too high.

Our second idea, and the one we have implemented in this version of the module, is to accept that we need to allow access to all DataDog IPs and in doing that we will try to minimize how many other IPs we allow traffic to.
Initially we decided to create CIDRs from all the IPs where we set the netmask to 24 bits but that still resulted in 400+ CIDRs.
Then we tried setting the netmask to 16 bits and that resulted in +80 CIDRs which is still too much for a single security group.
Finally with a netmask of 8 bits we were down to 7 CIDRs which is well within the limits of a Security Group.

Not all types of traffic that DataDog receives have such a long list of IPs behind it so we tried to find a good compromise per type of traffic.

| Type    | # IPs | Netmask | # CIDRs |
| ------- | ----- | ------- | ------- |
| agents  | +400  | /8      | 7       |
|         |       | /16     | +80     |
|         |       | /24     | +400    |
| process | +30   | /8      | 4       |
|         |       | /16     | +20     |
|         |       | /24     | +30     |    
| logs    | +100  | /8      | 8       |
|         | +100  | /16     | +70     |
|         | +100  | /24     | +100    |
| apm     | +10   | /32     | 10      |

The netmask sizes we chose allow us to fit all CIDRs into 3 Security Groups that allows traffic to all DataDog IPs, while also allowing traffic to a lot
(many many!) other IPs on the internet.
Still the number of IPs we allow traffic to is significantly less than the entire IP space (as we had to do before using this module).

Finally, we would like to also mention that the good people at DataDog are working internally to try and come up with a solution to the issue this module tries to address and we will be very happy to
discontinue our work in favour of what they can come up with.
Also, we would like to thank DataDog for the great work they do in general and for their contribution to this work in particular.

## Usage

Use this module to create security groups with outbound rules to allow the different types of traffic to reach DataDog.
Then configure the created security groups in other resources like `aws_instance` or `aws_launch_configuration`.
This module exports security groups both my name and id.

There are two types of security groups created:

* specific types of traffic for systems that only make use of a subset of features provided by DataDog
* combined types of traffic for systems that make use of most or all features provided by DataDog


### Dependencies

This module makes use of a few command line tools to gather the DataDog IPs:
* curl
* jq

### Example using combined traffic security groups

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
    "${module.datadog_firewall.combined_security_group_names}",
  ]

  tags {
    Name = "HelloWorld"
  }
}
```

### Example using specific traffic security groups

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

### Example setting VPC id

When input variable `vpc_id` is not set the security groups will be created in the default VPC of the account.

```hcl
provider "aws" {

}

module "datadog_firewall" {
  source = "https://github.com/Utilus/terraform-aws-datadog-firewall"
  
  project = "myProject"
  
  environment = "development"
  
  vpc_id = "my-vpc-id"
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
