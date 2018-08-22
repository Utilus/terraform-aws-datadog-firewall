#!/usr/bin/env sh

set -e
set -v

OVERRIDES_FILE=ci-overrides.tf
echo '
provider "aws" {
  region  = "string"
  profile = "string"
}
' >  ${OVERRIDES_FILE}

terraform init
terraform validate

rm -rf ci-*.tf*
