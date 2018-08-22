# encoding: utf-8
# copyright: 2018, The Authors

# load data from Terraform output
content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

describe aws_security_group(id: params['agent_security_group_id']['value']) do
  it { should exist }
  its('group_name') { should eq params['agent_security_group_name']['value'] }

  its('outbound_rules.count') { should cmp 2 }

  it { should allow_out(port: 123) }
  it { should allow_out(port: 443) }
end
