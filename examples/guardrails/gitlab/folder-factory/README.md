# Folder Factory

This is a template for a DevOps folder factory.

It can be used with [https://github.com/google/devops-governance/tree/main/examples/guardrails/project-factory](https://github.com/google/devops-governance/tree/main/examples/guardrails/project-factory) and is intended to house the folder configurations:

![Screenshot 2022-05-10 12 00 19 PM](https://user-images.githubusercontent.com/94000358/169809437-aaa8538e-3ffc-48b3-9028-84e4995de150.png)

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

Workload Identity setup between the folder factory gitlab repositories and the GCP Identity provider configured with a service account containing required permissions to create folders and their organizational policies. There is a sample code provided in “folder.yaml.sample” to create a folder and for terraform to create a folder minimum below permissions are required. 
“Folder Creator” or “Folder Admin” at org level
“Organization Policy Admin” at org level


### Installation Steps
From the folder-factory Gitlab project page
* CICD configuration file path 
    Navigate to Settings > CICD > expand General pipelines
    Update “CI/CD configuration file” value to the relative path of the gitlab-ci.yml file from the root directory
    e.g. .gitlab/workflows/.gitlab-ci.yml

* CI/CD variables
    Navigate to Settings > CICD > expand Variables
    Add the variables to the pipeline as described in the table below. 
    The same can be accessed from the  README.md file under .gitlab/workflows  in folder-factory. 

| Variable                       | Description                                                                                                                                              |Sample value                                                                                                |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| GCP_PROJECT_ID                 | The GCP project ID of your service account                                                                                                               | sample-project-1122                                                                                             |
| GCP_SERVICE_ACCOUNT            | The Service Account to be used for creating folders                                                                                                      | xyz@sample-project-1122.iam.gserviceaccount.com                                                                 |
| GCP_WORKLOAD_IDENTITY_PROVIDER | The Workload Identity provider URI configured with the Service Account and the repository                                                                | projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME} |
| STATE_BUCKET                   | The GCS bucket in which the state is to be centrally managed. The Service account provided above must have access to list and write files to this bucket. Use a seed project if running this as part of Foundations or create a new GCS Bucket. | sample-terraform-state-bucket                                                                                   |
| TF_LOG                         | The terraform env variable setting to get detailed logs.  Supports TRACE,DEBUG,INFO,WARN,ERROR in order of decreasing verbosity                          | WARN                                                                                                            |
| TF_ROOT                        | The directory of the terraform code to be executed.  Can be a path string or also a pre-defined gitlab CI variables                                      | $CI_PROJECT_DIR                                                                                                 |
| TF_VERSION                     | The terraform version to be used for execution. The specified terraform version is downloaded and used for execution for the workflow.                   | 1.3.6                                                                                                           |

* Once the prerequisites are set up, any commit to the remote main branch with changes to  *.tf, *.tfvars, data/*, modules/* files should trigger the pipeline.  


* .gcp-auth before-script should run successfully in the pipeline if the workload identity federation is configured as required.

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
             Runs terraform apply and  creates the infrastructure specified.


