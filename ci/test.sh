#!/usr/bin/env sh

cd test

terraform_dir=../.terraform
if [ -d "${terraform_dir}" ]; then

    echo "==> Re-using terraform plugins from previous job"
    cp -rf ../.terraform .

fi

echo "==> Initializing terraform"
terraform init

echo "==> Applying terraform configuration"
terraform apply -auto-approve -input=false
RETURN_VALUE=$?

if [ "${RETURN_VALUE}" -eq 0 ]; then

    terraform output --json > verify/files/terraform.json

    echo "==> Running tests"
    inspec exec verify -t aws://eu-west-1/nlo-gateway-dev-env
    RETURN_VALUE=$?

fi

echo "==> Destroying state"
terraform destroy -auto-approve -input=false

exit ${RETURN_VALUE}
