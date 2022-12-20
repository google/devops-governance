# Build Repository from Gitlab

Gitlab repository can be build with Cloud build by webhook triggers. This document covers the steps to setup webhooks triggers to build repository from gitlab:

## Prerequisites

* Enable the Cloud Build and secret manager API
* [Enable ssh access on gitlab](https://cloud.google.com/build/docs/automating-builds/gitlab/build-repos-from-gitlab#enabling_ssh_access_on_gitlab).


## Setup SSH Keys

1. To access the gitlab code, ssh keys needs to be retrieved in the inline build config.
2. Follow the steps in [this](https://cloud.google.com/build/docs/automating-builds/gitlab/build-repos-from-gitlab#creating_an_ssh_key) document to create ssh keys. 
3. [Add your public ssh access keys on gitlab](https://cloud.google.com/build/docs/automating-builds/gitlab/build-repos-from-gitlab#adding_your_public_ssh_access_key_on_gitlab).
4. [Add ssh key credentials in Secret Manager](https://cloud.google.com/build/docs/automating-builds/gitlab/build-repos-from-gitlab#webhook_triggers_create_store_secret).
5. [Create a webhook trigger  from the GCP console](https://cloud.google.com/build/docs/automating-builds/gitlab/build-repos-from-gitlab#creating_webhook_triggers).
6. [Create a webhook in gitlab](https://cloud.google.com/build/docs/automating-builds/gitlab/build-repos-from-gitlab#creating_a_webhook_in_gitlab) using the webhook URL generated in step #5.


## Update variable substitutions in webhook trigger


Following substitutions variables needs to be configured in cloud build trigger settings to complete cloud build trigger setup. 

variables:
```
  _BRANCH: $(body.ref)
  #  This variable provides information about the branch which invoked the trigger. Substitute its value with $(body.ref)
  _DEV_SECRET: 'projects/<GCP_PROJECT_ID>/secrets/<SECRET_NAME>/versions/<SECRET_VERSION>'
  # It contains the URI of a secret manager resource with an ssh key which has access to the target gitlab repository. E.g. projects/207296814713/secrets/gitlab-ssh/versions/1
  _FOLDER: 'XXXX'
  # It contains the directory with terraform configuration files which needs to be build when the trigger is invoked. E.g. examples/guardrails/skunkworks
  _REPOSITORY_NAME: $(body.repository.name)
  # It contains the name of the repository. Substitute its value with $(body.repository.name)
  _STATE_BUCKET: 'XXXX'
  # The GCS bucket to store the terraform state 
  _TO_SHA: $(body.after)
  # It contains the SHA of the commit that invoked the build. Substitute its value with $(body.after)
  _SSH_REPOSITORY_NAME: 'XXXX'
  # It contains the gitlab URL of the repository in SSH format. E.g. git@gitlab.com:pawanphalak/cloud-build-terraform-iac.git
```

