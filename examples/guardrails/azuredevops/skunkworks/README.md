# Skunkworks - IaC Kickstarter Template

This is a template for an IaC kickstarter repository.

<img width="1009" alt="Screenshot 2023-03-10 at 02 53 38" src="https://user-images.githubusercontent.com/94000358/224204810-ccf2b71a-875a-407d-8407-45cdf5f20eb5.png">

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on AzuredevopsAzure. It is based on the following "ideal" pipeline:

![Gitlab](https://user-images.githubusercontent.com/94000358/224205000-7cfb0fe0-6520-421b-88bd-ba7efb20ffd4.png)

This template creates a bucket in the specified target environment.

## How to run this stage

### Prerequisites 
Project factory is executed successfully and the respective service accounts for all the environments and projects are in place.


The branch structure should mirror the environments that are going to be deployed. For example, for deploying resources in dev, staging and prod skunkworks projects, three protected branches for dev, staging and prod are required.


### Installation Steps
1. Update the CICD configuration file path in the repository
    * From the skunkworks ADO repo ,  update CI/CD configuration file value to the relative path of the azure-pipeline.yml file 

2. Update the CI/CD variables
    * From the skunkworks repo, Add the below variables to the pipeline 

### Terraform config validator
The pipeline has an option to utilise the integrated config validator (gcloud terraform vet) to impose constraints on your terraform configuration. You can enable it by setting the CI/CD Variable $TERRAFORM_POLICY_VALIDATE to "true" and providing the policy-library repo URL to $POLICY_LIBRARY_REPO variable. See the below for details on the Variables to be set on the CI/CD pipeline.


| Variable                       | Description                                                                                                                                              | Sample value                                                                                                    |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| DEV_GCP_PROJECT_ID             | The GCP project ID in which resources are to be created on a push event to dev branch                                                                    | sample-dev-project-1122                                                                                         |
| DEV_GCP_SERVICE_ACCOUNT        | The Service Account of the dev gcp project configured with Workload Identity Federation (WIF)                                                            | xyz@sample-dev-project-1122.iam.gserviceaccount.com                                                             |
| STAGE_GCP_PROJECT_ID           | The GCP project ID in which resources are to be created on a push event to staging branch                                                                | sample-stage-project-1122                                                                                       |
| STAGE_GCP_SERVICE_ACCOUNT      | The Service Account of the staging gcp project configured with Workload Identity Federation (WIF)                                                        | xyz@sample-stage-project-1122.iam.gserviceaccount.com                                                           |
| PROD_GCP_PROJECT_ID            | The GCP project ID in which resources are to be created on a push event to prod branch                                                                   | sample-prod-project-1122                                                                                        |
| PROD_GCP_SERVICE_ACCOUNT       | The Service Account of the prod gcp project configured with Workload Identity Federation (WIF)                                                           | xyz@sample-prod-project-1122.iam.gserviceaccount.com                                                            |
| GCP_WORKLOAD_IDENTITY_PROVIDER | The Workload Identity provider URI configured with the Service Account and the repository                                                                | projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME} |
| STATE_BUCKET                   | The GCS bucket in which the state is to be centrally managed. The Service account provided above must have access to list and write files to this bucket | sample-terraform-state-bucket                                                                                   |
| TF_LOG                         | The terraform env variable setting to get detailed logs.  Supports TRACE,DEBUG,INFO,WARN,ERROR in order of decreasing verbosity                          | WARN                                                                                                            |
| TF_ROOT                        | The directory of the terraform code to be executed.   variables                                      | $CI_PROJECT_DIR                                                                                                 |
| TF_VERSION                     | The terraform version to be used for execution. The specified terraform version is downloaded and used for execution for the workflow.                   | 1.3.6
| TERRAFORM_POLICY_VALIDATE                         | Set this value as true if terraform vet is to be run against the policy library repository set in $POLICY_LIBRARY_REPO                           | true                                                                                                           |
| POLICY_LIBRARY_REPO                         | The policy library repository URL which will be cloned using git clone to run gcloud terraform vet against.                          | https://github.com/GoogleCloudPlatform/policy-library                                                                                                           |                                                                                                          |

## Pipeline Workflow Overview
The complete workflow contains a parent child pipeline. The parent(azure-pipeline.yaml) file is the trigger stage for each of the environments. It passes relevant variables for that environment to the child pipeline which executes the core terraform workflow. The child pipeline workflow executes 4-5 stages and 2 before-script jobs

* before_script jobs :
  * gcp-auth : creates the wif credentials by impersonating the service account.
  * terraform init : initializes terraform in the specified TF_ROOT directory
* Stages:
  * setup-terraform : Downloads the specified TF_VERSION and passes it as a binary to the next stages
  * validate: Runs terraform fmt check and terraform validate. This stage fails if the code is not run against terraform fmt command
  * plan: Runs terraform plan and saves the plan and json version of the plan as artifacts
  * policy-validate: Runs gcloud terraform vet against the terraform code with the constraints in the specified repository.
  * apply:  once the plan is successful. 
           Runs terraform apply and creates the infrastructure specified.
