# Build Repository from Secure Source Manager

Secure Source Manager is code repository
This file has all the information to pull a repo from secure source manager from cloud build.

## Prerequisites

* Enable the Cloud Build and secret manager API
* Give the cloud build service account the following roles:
    a. roles/secretmanager.secretAccessor
    b. roles/securesourcemanager.instanceAccessor
    c. roles/securesourcemanager.repoAdmin

* If you have to create a new repo:
    https://cloud.google.com/secure-source-manager/docs/create-repository

* If the repo is already created, the add an IAM role binding:
    `gcloud alpha source-manager instances add-iam-policy-binding <ssm_instance_name>  --region='<ssm_instance_region>' --project='cloud-professional-services' --member='<cloudbuild serviceaccount>' --role='roles/securesourcemanager.instanceAccessor'`


## Update variable substitutions in webhook trigger

Following substitutions variables needs to be configured in cloud build trigger settings to complete cloud build trigger setup. 

variables:
```
  _REPO_URL:  This variable provides information about secure source manager instance url.
  _REPO_NAME : This variable provides information about secure source manager repo name.
```

