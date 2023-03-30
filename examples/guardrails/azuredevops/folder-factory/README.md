# Folder Factory

This is a template for a DevOps folder factory.

It can be used with [https://github.com/google/devops-governance/tree/main/examples/guardrails/project-factory](https://github.com/google/devops-governance/tree/main/examples/guardrails/project-factory) and is intended to house the folder configurations:

<img width="1012" alt="Screenshot 2023-03-10 at 02 52 08" src="https://user-images.githubusercontent.com/94000358/224204373-f17024c0-1a2c-474b-82c2-affd8119cc05.png">

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github.


## Setting up folders

The folder factory will:
- create a folders with defined organisational policies

It uses YAML configuration files for every folder with the following sample structure:
```
parent: folders/XXXXXXXXX
org_policies:
  policy_boolean:
    constraints/compute.disableGuestAttributesAccess: true
    constraints/iam.disableServiceAccountCreation: false
    constraints/iam.disableServiceAccountKeyCreation: false  
    constraints/iam.disableServiceAccountKeyUpload: false
    constraints/gcp.disableCloudLogging: false 
  policy_list:
    constraints/compute.vmExternalIpAccess:
      inherit_from_parent: null
      status: true
      suggested_value: null
      values:
iam:
  roles/resourcemanager.projectCreator:
    - serviceAccount:XXXXX@XXXXXX
```

Every folder is defined with its own yaml file located in the following [Folder](data/folders).
Copy "folder.yaml.sample" to "folder_name.yaml"; Name of the yaml file will be used to create folder with the same name.
Once folder_name.yaml file is created update yaml file
  * parent - can be another folder or organization
  * ServiceAccount
data/folders can have multiple yaml files and a folder will be created for each yaml file.


## How to run this stage
### Prerequisites

Workload Identity setup between the folder factory code repositories and the GCP Identity provider configured with a service account containing required permissions to create folders and their organizational policies. There is a sample code provided in “folder.yaml.sample” to create a folder and for terraform to create a folder minimum below permissions are required. 
“Folder Creator” or “Folder Admin” at org level
“Organization Policy Admin” at org level


### Installation Steps
From the folder-factory edit the azure-pipeline.yml

* CI/CD variables
    
    Add the variables to the pipeline as described in the table below. 
    

### Terraform config validator
The pipeline has an option to utilise the integrated config validator (gcloud terraform vet) to impose constraints on your terraform configuration. You can enable it by setting the CI/CD Variable $TERRAFORM_POLICY_VALIDATE to "true" and providing the policy-library repo URL to $POLICY_LIBRARY_REPO variable. See the below for details on the Variables to be set on the CI/CD pipeline.


| Variable                       | Description                                                                                                                                              |Sample value                                                                                                |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| GCP_PROJECT_ID                 | The GCP project ID of your service account                                                                                                               | sample-project-1122                                                                                             |
| GCP_SERVICE_ACCOUNT            | The Service Account to be used for creating folders                                                                                                      | xyz@sample-project-1122.iam.gserviceaccount.com                                                                 |
| GCP_WORKLOAD_IDENTITY_PROVIDER | The Workload Identity provider URI configured with the Service Account and the repository                                                                | projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME} |
| STATE_BUCKET                   | The GCS bucket in which the state is to be centrally managed. The Service account provided above must have access to list and write files to this bucket. Use a seed project if running this as part of Foundations or create a new GCS Bucket. | sample-terraform-state-bucket                                                                                   |
| TF_LOG                         | The terraform env variable setting to get detailed logs.  Supports TRACE,DEBUG,INFO,WARN,ERROR in order of decreasing verbosity                          | WARN                                                                                                            |
| TF_ROOT                        | The directory of the terraform code to be executed.                                    | $CI_PROJECT_DIR                                                                                                 |
| TF_VERSION                     | The terraform version to be used for execution. The specified terraform version is downloaded and used for execution for the workflow.                   | 1.3.6
| TERRAFORM_POLICY_VALIDATE                         | Set this value as true if terraform vet is to be run against the policy library repository set in $POLICY_LIBRARY_REPO variable                          | true                                                                                                           |
| POLICY_LIBRARY_REPO                         | The policy library repository URL which will be cloned using git clone to run gcloud terraform vet against.                          | https://github.com/GoogleCloudPlatform/policy-library  

* Once the prerequisites are set up, trigger the pipeline manually or set the trigger as per your need. 


* .gcp-auth script should run successfully in the pipeline if the workload identity federation is configured as required.

### Pipeline Workflow Overview
The complete workflow comprises of 4-5 stages 
  * Stages:
    * gcp-auth : creates the wif credentials by impersonating the service account.
    * terraform init : initializes terraform in the specified TF_ROOT directory
    * setup-terraform : Downloads the specified TF_VERSION and passes it as a binary to the next stages
    * validate: Runs terraform fmt check and terraform validate. This stage fails if the code is not run against terraform fmt command
    * plan: Runs terraform plan and saves the plan and json version of the plan as artifacts
    * policy-validate: Runs gcloud terraform vet against the terraform code with the constraints in the specified repository.
    * apply: once the plan is successful. 
             Runs terraform apply and  creates the infrastructure specified.

