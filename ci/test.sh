#!/usr/bin/env sh


cd test

terraform_dir=../.terraform
if [ -d "${terraform_dir}" ]; then

    cp -rf ../.terraform .

else

    terraform init

fi

terraform apply -auto-approve -input=false
RETURN_VALUE=$?

if [ "${RETURN_VALUE}" -eq 0 ]; then

    terraform output --json > verify/files/terraform.json

    inspec exec verify -t aws://eu-west-1/nlo-gateway-dev-env
    RETURN_VALUE=$?
fi

terraform destroy -auto-approve -input=false

exit ${RETURN_VALUE}
