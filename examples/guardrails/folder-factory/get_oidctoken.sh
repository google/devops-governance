#!/bin/bash 
echo -n "${BITBUCKET_STEP_OIDC_TOKEN}" > /tmp/gcp_access_token.out
gcloud iam workload-identity-pools create-cred-config "projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${workload_identity_pool_id}/providers/${workload_identity_pool_provider_id}" --credential-source-file=/tmp/gcp_access_token.out --service-account="${SERVICE_ACCOUNT_EMAIL}" --output-file=sts-creds.json
export GOOGLE_APPLICATION_CREDENTIALS=`pwd`/sts-creds.json
gcloud auth login --cred-file=`pwd`/sts-creds.json
gcloud config set project $PROJECT_NAME
gcloud services list