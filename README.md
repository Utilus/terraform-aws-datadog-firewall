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
