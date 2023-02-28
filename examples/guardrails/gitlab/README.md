This workflow runs terraform pipelines using Gitlab CICD. This document covers the steps to setup Gitlab CICD and provides a high level overview of the stages involved.

Please look through the [README](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/README.md) for an overview of CICD process.


## How to Run this stage 
* Create a gitlab account
* Create a Group in gitlab
* Add a project called “folder-factory” and copy code from devops [folder factory repo](https://github.com/google/devops-governance/tree/GDC-phase-kickstarter-1/examples/guardrails/gitlab/folder-factory) into it
* Add project called “project-factory” and copy code from devops [project factory repo](https://github.com/google/devops-governance/tree/GDC-phase-kickstarter-1/examples/guardrails/gitlab/project-factory) into it
* Add a project called “skunkworks” and copy code from devops [skunkworks repo](https://github.com/google/devops-governance/tree/GDC-phase-kickstarter-1/examples/guardrails/gitlab/skunkworks) into it.
* Workload Identity setup between the folder factory gitlab repositories and the GCP Identity provider configured with a service account containing required permissions to create folders and their organizational policies. 


* For further details on workload identity federation setup for Gitlab with GCP, please refer to the official Gitlab Documentation
* Available self hosted or SaaS Gitlab runners to run the pipelines.



Prerequisites
A Gitlab project containing the folder-factory repository
Available Gitlab Runners for the project either self hosted or the SaaS Gitlab shared runners.
A working WIF provider, pool setup with audience as gitlab.com with neccessary attributes and linked service account with required permissions. For further details, please refer to the official Gitlab Documentation
Setup
Update the CICD configuration file path in the repository

Terraform pipeline execution with Gitlab runners and Gitlab repository

From the folder-factory Gitlab project page, Navigate to Settings > CICD > expand General pipelines
update CI/CD configuration file value to the relative path of the gitlab-ci.yml file from the root directory
Update the CI/CD variables

From the folder-factory project page, Navigate to Settings > CICD > expand Variables
Add the below variables to the pipeline
Variable	Description	Sample value
GCP_PROJECT_ID	The GCP project ID of your service account	sample-project-1122
GCP_SERVICE_ACCOUNT	The Service Account to be used for creating folders	xyz@sample-project-1122.iam.gserviceaccount.com
GCP_WORKLOAD_IDENTITY_PROVIDER	The Workload Identity provider URI configured with the Service Account and the repository	projects//locations/global/workloadIdentityPools//providers/
STATE_BUCKET	The GCS bucket in which the state is to be centrally managed. The Service account provided above must have access to list and write files to this bucket	sample-terraform-state-bucket
TF_LOG	The terraform env variable setting to get detailed logs. Supports TRACE,DEBUG,INFO,WARN,ERROR in order of decreasing verbosity	WARN
TF_ROOT	The directory of the terraform code to be executed. Can be a path string or also a pre-defined gitlab CI variables	$CI_PROJECT_DIR
TF_VERSION	The terraform version to be used for execution. The specified terraform version is downloaded and used for execution for the workflow.	1.3.6
Overview of the Pipeline stages
The complete workflow consists of 4 stages and 2 before-script jobs

before_script jobs :

gcp-auth : creates the wif credentials by impersonating the service account.
terraform init : initializes terraform in the specified TF_ROOT directory
Stages:

setup-terraform : Downloads the specified TF_VERSION and passes it as a binary to the next stages
validate: Runs terraform fmt check and terraform validate. This stage fails if the code is not run against terraform fmt command
plan: Runs terraform plan and saves the plan and json version of the plan as artifacts
apply: This step is currently set as manual to be triggered from the Gitlab pipelines UI once plan is successful. Runs terraform apply and creates the infrastructure specified.
