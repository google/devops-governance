# Cloudbuild guardrail & pipeline example for individual workloads

To demonstrate how to enforce guardrails and pipelines for Google Cloud we provide the "Guardrail Examples". The purpose of these examples is demonstrate how to provision access & guardrails to new workloads with IaC. 

> A more comprehensive description of DevOps & GitOps principles can be found at [DevOps README](./../../../README.md). 


### Implementation Process
Gitlab repository can be build with Cloud build by webhook triggers. Following are the steps to setup webhooks triggers to build repository from gitlab:

### Prerequisites
Enable the Cloud Build and secret manager API
Create a GCS bucket to store the terraform state file. Note: The bucket name will be configured as a cloud build variable substitutions while creating the cloud build trigger.
Gitlab repository with Folder Factory, Project Factory and Skunkworks Terraform code.
Note: SSH access on the gitlab repository should be given to allow users on the server to add their own ssh keys and use those ssh keys to secure git operations between their computer and gitlab instance. 

### Setup SSH Keys

1. Follow the steps here to complete the ssh key setup and cloud build trigger creation and Gitlab webhook setup, which involves following steps:
* Follow the steps in this document to create ssh keys. 
-   The ssh keys are required to access the gitlab repository code, these ssh keys are added in the GCP secret manager, which is then retrieved in the cloud build inline configuration to clone the gitlab repository.
* Add your public ssh access keys on gitlab.
- This step allows the ssh keys access to clone the gitlab repository in cloud build jobs.
* Add ssh key credentials in Secret Manager.
- These ssh keys have access to clone the gitlab repository. Note: The cloud build trigger created in the following steps should have the  Secret Manager Secret Accessor IAM role on the service account assigned to the cloud build trigger.
* Create a webhook trigger  from the GCP console.
- This webhook trigger is responsible for running the CICD job to deploy the terraform code. Note: This step also involves creating a GCP secret version which is different from the secret created in step 1.c. This secret is used by the cloud build webhook URL to send webhook events from gitlab.
* Create a webhook in Gitlab 
- Using the webhook URL generated on cloudbuild side, configure the hook on Gitlab. 
2. (Optional) Use the test feature on the Gitlab webhook section to make sure changes on Gitlab send a trigger to cloudbuild. 
The cloud build webhook created with sample cloud build inline configuration can be triggered to validate the working of the webhook trigger. Navigate to Cloudbuild > Settings > Webhooks page to send the webhook trigger event by clicking the push event(or the event for which the gitlab trigger is configured):

IMAGE 

This will invoke the cloud build job in the GCP console.

3. Update the inline cloud build config for cloud build trigger created in step #5 with respective cloudbuild CICD file for the project. I.e. 
Folder Factory cloud build inline build config.
Project Factory cloud build inline build config.
Skunkworks cloud build inline build config. The skunkworks cloud build config files are created for following environments:
Development:  Note: This config file is implemented for the development environment and will be only deployed if the cloud build is triggered from the “dev” branch, this can be updated by updating the “If condition” in “Terraform Apply” Stage.
Staging:  Note: This config file is implemented for the staging  environment and will be only deployed if the cloud build is triggered from the “staging” branch, this can be updated by updating the “If condition” in “Terraform Apply” Stage.
Production:  Note: This config file is implemented for the production environment and will be only deployed if the cloud build is triggered from the “main” branch, this can be updated by updating the “If condition” in “Terraform Apply” Stage.
