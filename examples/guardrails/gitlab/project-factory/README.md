# Project Factory

This is a template for a DevOps project factory.

It can be used with https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory (https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory) and is intended to house the projects of a specified folder:

<img width="1466" alt="Overview" src="https://user-images.githubusercontent.com/94000358/161531177-23a99468-1e7b-4583-a243-624ee4663506.png">

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

![Folder Factory](https://user-images.githubusercontent.com/94000358/169809882-f5ff9fb1-d037-49de-8c2c-bf0d457b662f.png)

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github.


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
The parent folders are provisioned to place the projects.


Workload Identity setup between the project factory gitlab repositories and the GCP Identity provider configured with a service account containing required permissions to create projects, workload identity pools and providers, service accounts and IAM bindings on the service accounts under the parent folder in which the projects are to be created.
“Project Creator” should already be granted when running the folder factory.
“Billing User” on Billing Account

### Installation Steps
From the project-factory Gitlab project page
CICD configuration file path 
Navigate to Settings > CICD > expand General pipelines
Update “CI/CD configuration file” value to the relative path of the gitlab-ci.yml file from the root directory
e.g. .gitlab/workflows/.gitlab-ci.yml

CI/CD variables
Navigate to Settings > CICD > expand Variables
Add the variables to the pipeline as described in the table below. The same can be accessed from the  README.md file under .gitlab/workflows in project-factory.

| Variable                       | Description                                                                                                                                              | Sample value                                                                                                    |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| GCP_PROJECT_ID                 | The GCP project ID of your service account                                                                                                               | sample-project-1122                                                                                             |
| GCP_SERVICE_ACCOUNT            | The Service Account to be used for creating projects                                                                                                      | xyz@sample-project-1122.iam.gserviceaccount.com                                                                 |
| GCP_WORKLOAD_IDENTITY_PROVIDER | The Workload Identity provider URI configured with the Service Account and the repository                                                                | projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME} |
| STATE_BUCKET                   | The GCS bucket in which the state is to be centrally managed. The Service account provided above must have access to list and write files to this bucket | sample-terraform-state-bucket                                                                                   |
| TF_LOG                         | The terraform env variable setting to get detailed logs.  Supports TRACE,DEBUG,INFO,WARN,ERROR in order of decreasing verbosity                          | WARN                                                                                                            |
| TF_ROOT                        | The directory of the terraform code to be executed.  Can be a path string or also a pre-defined gitlab CI variables                                      | $CI_PROJECT_DIR                                                                                                 |
| TF_VERSION                     | The terraform version to be used for execution. The specified terraform version is downloaded and used for execution for the workflow.                   | 1.3.6  |                                                                                                          |

Similar to Folder factory, 

Once the prerequisites are set up, any commit to the remote main branch with changes to  *.tf, *.tfvars, data/*, modules/* files should trigger the pipeline.  

.gcp-auth before-script should run successfully in the pipeline if the workload identity federation is configured as required.

### Pipeline Workflow Overview
The complete workflow comprises of 4 stages and 2 before-script jobs
* before_script jobs :
  * gcp-auth : creates the wif credentials by impersonating the service account.
  * terraform init : initializes terraform in the specified TF_ROOT directory
* Stages:
  * setup-terraform : Downloads the specified TF_VERSION and passes it as a binary to the next stages
  * validate: Runs terraform fmt check and terraform validate. This stage fails if the code is not run against terraform fmt command
  * plan: Runs terraform plan and saves the plan and json version of the plan as artifacts
  * apply: This step is currently set as manual to be triggered from the Gitlab pipelines UI once the plan is successful. 
          Runs terraform apply and creates the infrastructure specified.
