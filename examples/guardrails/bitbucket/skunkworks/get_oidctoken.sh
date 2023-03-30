#!/bin/bash 
set -e
echo ${BITBUCKET_STEP_OIDC_TOKEN} > /tmp/gcp_access_token.out
gcloud iam workload-identity-pools create-cred-config ${GCP_WORKLOAD_IDENTITY_PROVIDER} --service-account="${GCP_SERVICE_ACCOUNT}" --output-file=.gcp_temp_cred.json --credential-source-file=/tmp/gcp_access_token.out
gcloud auth login --cred-file=`pwd`/.gcp_temp_cred.json
gcloud projects list
gcloud config set project $PROJECT_NAME
export GOOGLE_APPLICATION_CREDENTIALS=`pwd`/.gcp_temp_cred.json