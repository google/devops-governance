# Skunkworks - IaC Kickstarter Template

This is a template for an IaC kickstarter repository.

![Skunkworks](https://user-images.githubusercontent.com/94000358/169810982-36f01de2-e5e5-4ecd-b98e-3cf5a6aa9f81.png)

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github. 

This template creates a bucket in the specified target environment.

## How to run this stage

### Prerequisites 
Project factory is executed successfully and the respective service accounts for all the environments and projects are in place.


The branch structure should mirror the environments that are going to be deployed. For example, for deploying resources in dev, staging and prod skunkworks projects, three protected branches for dev, staging and prod are required.


### Installation Steps
Update the CICD configuration file path in the repository
    * From the skunkworks Gitlab project page, Navigate to Settings > CICD > expand General pipelines 
    * update CI/CD configuration file value to the relative path of the gitlab-ci.yml file from the root directory

2. Update the CI/CD variables
    * From the skunkworks project page, Navigate to Settings > CICD > expand Variables
    * Add the below variables to the pipeline 

| Variable                       | Description                                                                                                                                              | Sample value                                                                                                    |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| DEV_GCP_PROJECT_ID             | The GCP project ID in which resources are to be created on a push event to dev branch                                                                    | sample-dev-project-1122                                                                                         |
| DEV_GCP_SERVICE_ACCOUNT        | The Service Account of the dev gcp project configured with Workload Identity Federation (WIF)                                                            | xyz@sample-dev-project-1122.iam.gserviceaccount.com                                                             |
| STAGE_GCP_PROJECT_ID           | The GCP project ID in which resources are to be created on a push event to staging branch                                                                | sample-stage-project-1122                                                                                       |
| STAGE_GCP_SERVICE_ACCOUNT      | The Service Account of the staging gcp project configured with Workload Identity Federation (WIF)                                                        | xyz@sample-stage-project-1122.iam.gserviceaccount.com                                                           |
| PROD_GCP_PROJECT_ID            | The GCP project ID in which resources are to be created on a push event to prod branch                                                                   | sample-prod-project-1122                                                                                        |
| PROD_GCP_SERVICE_ACCOUNT       | The Service Account of the prod gcp project configured with Workload Identity Federation (WIF)                                                           | xyz@sample-prod-project-1122.iam.gserviceaccount.com                                                            |
| GCP_WORKLOAD_IDENTITY_PROVIDER | The Workload Identity provider URI configured with the Service Account and the repository                                                                | projects/<project-number>/locations/global/workloadIdentityPools/<identity-pool-name>/providers/<provider-name> |
| STATE_BUCKET                   | The GCS bucket in which the state is to be centrally managed. The Service account provided above must have access to list and write files to this bucket | sample-terraform-state-bucket                                                                                   |
| TF_LOG                         | The terraform env variable setting to get detailed logs.  Supports TRACE,DEBUG,INFO,WARN,ERROR in order of decreasing verbosity                          | WARN                                                                                                            |
| TF_ROOT                        | The directory of the terraform code to be executed.  Can be a path string or also a pre-defined gitlab CI variables                                      | $CI_PROJECT_DIR                                                                                                 |
| TF_VERSION                     | The terraform version to be used for execution. The specified terraform version is downloaded and used for execution for the workflow.                   | 1.3.6                                                                                                           |                                                                                                          |

## Pipeline Workflow Overview
The complete workflow contains a parent child pipeline. The parent(.gitlab-ci.yaml) file is the trigger stage for each of the environments. It passes relevant variables for that environment to the child pipeline which executes the core terraform workflow. The child pipeline workflow executes 4 stages and 2 before-script jobs

* before_script jobs :
  * gcp-auth : creates the wif credentials by impersonating the service account.
  * terraform init : initializes terraform in the specified TF_ROOT directory
* Stages:
  * setup-terraform : Downloads the specified TF_VERSION and passes it as a binary to the next stages
  * validate: Runs terraform fmt check and terraform validate. This stage fails if the code is not run against terraform fmt command
  * plan: Runs terraform plan and saves the plan and json version of the plan as artifacts
  * apply: This step is currently set as manual to be triggered from the Gitlab pipelines UI once the plan is successful. 
           Runs terraform apply and creates the infrastructure specified.

