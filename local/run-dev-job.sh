#!/usr/bin/env bash

JOB_NAME=$1

if [ -z "${JOB_NAME}" ]; then

    echo "==# Need job name as first argument to run script"
    exit 1

fi

if [ -z "${ENV_AWS_ACCESS_KEY_ID}" ]; then

    echo "==# Need dev env ENV_AWS_ACCESS_KEY_ID in the shell environment ro run script"
    exit 1

fi

if [ -z "${ENV_AWS_SECRET_ACCESS_KEY}" ]; then

    echo "==# Need dev env ENV_AWS_SECRET_ACCESS_KEY in the shell environment ro run script"
    exit 1

fi

gitlab-runner exec docker \
    --env UTILUS_BOT_SSH_KEY="$(cat ~/.ssh/utilus-bot-id_rsa)" \
    --env DEV_AWS_ACCESS_KEY_ID="${ENV_AWS_ACCESS_KEY_ID}" \
    --env DEV_AWS_SECRET_ACCESS_KEY="${ENV_AWS_SECRET_ACCESS_KEY}" \
    ${JOB_NAME}
