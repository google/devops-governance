# Cloudbuild guardrail & pipeline example for individual workloads

This workflow covers the steps to setup webhooks in GCP Cloud Build and gitlab to build the repository in gitlab using GCP Cloud build runners. The gitlab with cloud build setup involves creating webhooks in cloud build and gitlab. The webhook is then triggered based on the selected events(e.g. Push event) to trigger Cloud Build pipeline. 

> A more comprehensive description of DevOps & GitOps principles can be found at [DevOps README](./../../../README.md). 


## Implementation Process
Gitlab repository can be build with Cloud build by webhook triggers. Following are the steps to setup webhooks triggers to build repository from gitlab:

### Prerequisites
* Enable the Cloud Build and secret manager API
* Create a GCS bucket to store the terraform state file. Note: The bucket name will be configured as a cloud build variable substitutions while creating the cloud build trigger.
* Gitlab repository with Folder Factory, Project Factory and Skunkworks Terraform code.
* **Note**: SSH access on the gitlab repository should be given to allow users on the server to add their own ssh keys and use those ssh keys to secure git operations between their computer and gitlab instance. 

### Setup SSH Keys

1. Follow the steps [here](https://cloud.google.com/build/docs/automating-builds/gitlab/build-repos-from-gitlab#setting_up) to complete the ssh key setup and cloud build trigger creation and Gitlab webhook setup, which involves following steps:
   * Create ssh keys. 
     * The ssh keys are required to access the gitlab repository code, these ssh keys are added in the GCP secret manager, which is then retrieved in the cloud build inline configuration to clone the gitlab repository.
   * Add your public ssh access keys on gitlab.
     * This step allows the ssh keys access to clone the gitlab repository in cloud build jobs.
   * Add ssh key credentials in Secret Manager.
     * These ssh keys have access to clone the gitlab repository. Note: The cloud build trigger created in the following steps should have the  Secret Manager Secret Accessor IAM role on the service account assigned to the cloud build trigger.
   * Create a webhook trigger  from the GCP console.
     * This webhook trigger is responsible for running the CICD job to deploy the terraform code. Note: This step also involves creating a GCP secret version which is different from the secret created in step 1.c. This secret is used by the cloud build webhook URL to send webhook events from gitlab.
   * Create a webhook in Gitlab 
     * Using the webhook URL generated on cloudbuild side, configure the hook on Gitlab. 

2. (Optional) Use the test feature on the Gitlab webhook section to make sure changes on Gitlab send a trigger to cloudbuild. 
  * The cloud build webhook created with sample cloud build inline configuration can be triggered to validate the working of the webhook trigger. 
  * Navigate to Cloudbuild > Settings > Webhooks page to send the webhook trigger event by clicking the push event(or the event for which the gitlab trigger is configured):

![webhook](https://user-images.githubusercontent.com/105412459/224610214-4d1b1988-e7ce-4e6a-9b01-09db3059cb8e.png)


  * This will invoke the cloud build job in the GCP console.

3. Update the inline cloud build config for cloud build trigger created in step #5 with respective cloudbuild CICD file for the project. I.e. 
  * [Folder Factory cloud build inline build config](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/examples/guardrails/cloudbuild/folder-factory/.cloudbuild/workflows/cloudbuild.yaml).
  * [Project Factory cloud build inline build config.](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/examples/guardrails/cloudbuild/project-factory/.cloudbuild/workflows/cloudbuild.yaml)
  * [Skunkworks cloud build inline build config.](https://github.com/google/devops-governance/tree/GDC-phase-kickstarter-1/examples/guardrails/cloudbuild/skunkworks/.cloudbuild/workflows) The skunkworks cloud build config files are created for following environments:
    * [Development](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/examples/guardrails/cloudbuild/skunkworks/.cloudbuild/workflows/tf-cloudbuild-dev.yaml):  Note: This config file is implemented for the development environment and will be only deployed if the cloud build is triggered from the “dev” branch, this can be updated by updating the “If condition” in “Terraform Apply” Stage.
    * [Staging](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/examples/guardrails/cloudbuild/skunkworks/.cloudbuild/workflows/tf-cloudbuild-stage.yaml):  Note: This config file is implemented for the staging  environment and will be only deployed if the cloud build is triggered from the “staging” branch, this can be updated by updating the “If condition” in “Terraform Apply” Stage.
    * [Production](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/examples/guardrails/cloudbuild/skunkworks/.cloudbuild/workflows/tf-cloudbuild-prod.yaml):  Note: This config file is implemented for the production environment and will be only deployed if the cloud build is triggered from the “main” branch, this can be updated by updating the “If condition” in “Terraform Apply” Stage.
  
### Update variable substitutions in webhook trigger

* Following substitutions variables needs to be configured in cloud build trigger to complete cloud build trigger setup:

| KEY | VALUE |DESCRIPTION | REQUIRED |
|-----|-------|------------|----------|
| _BRANCH | $(body.ref) | This variable provides information about the branch which invoked the trigger. | YES |
| _SECRET | E.g. projects/123456789/secrets/gitlab-ssh/versions/1 | It contains the URI of a secret manager resource with an ssh key which has access to the target gitlab repository. | Only required for project factory and folder factory |
| _DEV_SECRET | E.g. projects/123456789/secrets/gitlab-ssh/versions/1 | It contains the URI of a secret manager resource with an ssh key which has access to the target gitlab repository. | This variable is only required to be configured for configuring the Skunkworks Development environment using the tf-cloudbuild-dev.yaml file. |
| _STAGE_SECRET |  E.g. projects/123456789/secrets/gitlab-ssh/versions/1 | It contains the URI of a secret manager resource with an ssh key which has access to the target gitlab repository. | This variable is only required to be configured for configuring Skunkworks Staging environment using tf-cloudbuild-stage.yaml file. |
| _PROD_SECRET |   E.g. projects/123456789/secrets/gitlab-ssh/versions/1 | It contains the URI of a secret manager resource with an ssh key which has access to the target gitlab repository. | This variable is only required to be configured for configuring the Skunkworks Production environment using tf-cloudbuild-prod.yaml file. |
| _FOLDER |   E.g. <br />For skunkworks project update the value with: examples/guardrails/skunkworks.<br /> For folder factory project update the value with: examples/guardrails/folder-factory. <br />For project factory project update the value with: examples/guardrails/project-factory
 |  It contains the directory with terraform configuration files which needs to be build when the trigger is invoked. | YES |
| _REPOSITORY_NAME |   $(body.repository.name) |   It contains the name of the repository. | YES |
| _STATE_BUCKET |   E.g terraform-us-bucket |   It contains the name of the GCS bucket where terraform state files are stored. | YES |
| _TO_SHA |   $(body.after) |    It contains the SHA of the commit that invoked the build. | YES |
| _SSH_REPOSITORY_NAME |   E.g. git@gitlab.com:pawanphalak/cloud-build-terraform-iac.git |  It contains the gitlab URL of the repository in SSH format.  | YES |


### Service account for Cloud Build Jobs

Cloud Build Jobs IAM permissions can be given by assigning a service account to a Cloud Build Trigger. The service account should have a Secret Manager Secret Accessor IAM role on the secret created during setting up the gitlab ssh keys. The service account should also have the required IAM roles to provision the GCP resources.

### Troubleshooting

1. [Cloud Build](https://cloud.google.com/build/docs/securing-builds/store-manage-build-logs#viewing_build_logs) logs can be viewed in the GCP console to troubleshoot any IAM permissions/CICD script errors.
Add below in cloudbuild.yaml to have a better understanding of tf plan
  ```yaml              
  logsBucket: 'gs://${_LOG_BUCKET_NAME}'
  options:
    logging: GCS_ONLY
  ```
2. Validate the ssh keys have access to the gitlab clone repository. Open a terminal and run this command, replacing gitlab.example.com with your GitLab instance URL and id_gitlab with the path of the ssh keys with gitlab access:
  ```
  ssh -T git@gitlab.example.com  -i id_gitlab
  ```

3. If the Cloud Build Job is not able to find any terraform configuration files, check if the path to the terraform configurations are set correctly in _FOLDER variable of cloud build trigger. If terraform configuration files are at the repository level keep the _FOLDER value as empty. More details about the dir parameter used with _FOLDER can be found [here](https://cloud.google.com/build/docs/build-config-file-schema#dir).


4. Do we need to create different cloud build triggers for different env’s? 

    Yes, the cloud build trigger should be created separately for each environment. The skunkworks project is configured for different environments(development, staging and production). More details for updating cloudbuild inline configurations to configure with each environment are covered in the above section with skunkworks project setup.
