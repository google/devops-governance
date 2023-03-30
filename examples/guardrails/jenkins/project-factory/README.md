# Project Factory

This is a template for a DevOps project factory.

It can be used with https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory (https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory) and is intended to house the projects of a specified folder:

<img width="1466" alt="Overview" src="https://user-images.githubusercontent.com/94000358/161531177-23a99468-1e7b-4583-a243-624ee4663506.png">

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

![Folder Factory](https://user-images.githubusercontent.com/94000358/169809882-f5ff9fb1-d037-49de-8c2c-bf0d457b662f.png)

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github.

## Repository Configuration
This repository does not need any additional runners (uses Github runners) and does require you to previously setup Workload Identity Federation to authenticate.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw

After setting up WIF you can then go ahead and configure this repository. This can be done by either with setting the following secrets:

<img width="785" alt="Secret settings" src="https://user-images.githubusercontent.com/94000358/161528557-41446670-1e3b-4ea1-996d-e377e53d9c43.png">

or by modifing the [Workflow Action](.github/workflows/terraform-deployment.yml) and setting the environment variables:
```
env:
  STATE_BUCKET: 'XXXX'
  # The GCS bucket to store the terraform state 
  FOLDER: 'folders/XXXX'
  # The folder under which the projects should be created
  WORKLOAD_IDENTITY_PROVIDER: 'projects/XXXX'
  # The workload identity provider that should be used for this repository.
  SERVICE_ACCOUNT: 'XXXX@XXXX'
  # The service account that should be used for this repository.
```

## Setting up projects

The project factory will:
- create a service account with defined rights
- create a project within the folder
- connect the service account to the Github repository informantion

It uses YAML configuration files for every project with the following sample structure:
```
billing_account_id: XXXXXX-XXXXXX-XXXXXX
roles:
    - roles/viewer
    - roles/iam.serviceAccountUser
    - roles/iam.securityReviewer
    - roles/monitoring.viewer
    - roles/monitoring.editor
    - roles/monitoring.alertPolicyViewer
    - roles/monitoring.alertPolicyEditor
    - roles/monitoring.dashboardViewer
    - roles/monitoring.dashboardEditor
    - roles/monitoring.notificationChannelViewer
    - roles/monitoring.notificationChannelEditor
    - roles/monitoring.servicesViewer
    - roles/monitoring.servicesEditor
    - roles/monitoring.uptimeCheckConfigViewer
    - roles/monitoring.uptimeCheckConfigEditor
    - roles/secretmanager.viewer
    - roles/secretmanager.secretVersionManager
    - roles/secretmanager.admin
    - roles/storage.admin
    - roles/storage.objectAdmin
    - roles/storage.objectCreator
    - roles/storage.objectViewer
repo_provider: github
repo_name: devops-governance/skunkworks
repo_branch: dev
```

Every project is defined with its own file located in the [Project Folder](data/projects).

## How to run this stage
### Prerequisites

Workload Identity setup between the folder factory gitlab repositories and the GCP Identity provider configured with a service account containing required permissions to create folders and their organizational policies. There is a sample code provided in “folder.yaml.sample” to create a folder and for terraform to create a folder minimum below permissions are required. 
“Folder Creator” or “Folder Admin” at org level
“Organization Policy Admin” at org level


### Installation Steps

Step 1: Create a bucket for terraform backend on the GCP environment.
Step 2: Create Jenkins Pipeline on Jenkins.
Step 3: Configure the below variables on Jenkins Credentials.

### Terraform config validator
The pipeline has an option to utilise the integrated config validator (gcloud terraform vet) to impose constraints on your terraform configuration. You have to provide the policy-library repo URL to $POLICY_LIBRARY_REPO variable. See the below for details on the Variables to be set on the CI/CD pipeline.


| Variable                      |                                                                                                                                                        | Example Value                                 |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------- |
| PROJECT_NAME                  | The project containing the service account that has permission to communicate with the WIF provider. Should be created as part of Project Factory.     | jenkins-connect-prj                         |
| GCP_PROJECT_NUMBER            | Project number for the project that hosts the WIF provider                                                                                             | 107999111999                                  |
| SERVICE_ACCOUNT_NAME          | The name of the service account that will be used to deploy. Must be hosted in PROJECT_NAME.                                                           | jenkins-sa                               |
| BUCKET_PATH                   | A state bucket that will hold the terraform state. This bucket must previously exist and the service account must have permission to read/write to it. | jenkins-gcs-state-bucket-name                         |
| policy_file_path          | https://github.com/GoogleCloudPlatform/policy-library                                                                                                  | The public repo where the policies are hosted |
| workload_identity_pool_id     |                                                                                                                                                        | jenkins-test-pool                           |
| workload_identity_provider_id |                                                                                                                                                        | jenkins-test-provider                       |                                                                                                |

* Once the prerequisites are set up, any commit to the remote main branch with changes to  *.tf, *.tfvars, data/*, modules/* files should trigger the pipeline.  


### Pipeline Workflow Overview
The complete workflow comprises of 6 stages and 2 before-script jobs
  * Stages:
    * Clean workspace : This step cleans the previous packages from Jenkins workspace
    * WIF : Execute the Workload Identity Federation script and generate credential file.
    * Terraform plan: Runs terraform plan and saves the plan and json version of the plan as artifacts, this depends on the branch
    * Terraform validate: Runs gcloud terraform vet against the terraform code with the constraints in the specified repository.
    * apply: This is executed for specified list of branches, currently main/master


