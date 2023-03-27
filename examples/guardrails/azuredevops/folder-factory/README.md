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

This is a YAML file for Azure DevOps that sets up a CI/CD pipeline for deploying infrastructure to Google Cloud Platform (GCP) using Terraform. It leverages Workload Identity Federation for authentication and integrates with Google Cloud's Policy Library for enforcing infrastructure policies. Let me break down the pipeline components:

1.  `name: "$(Date:yyyyMMdd)$(Rev:.r)"`: Sets the pipeline's name with a date and revision pattern. This provides a unique identifier for each pipeline run.
1.  `trigger`: Specifies that the pipeline should  be triggered manually or will  be automatically triggered by any changes to the repository.
1.  `variables`: Defines several variables to be used throughout the pipeline, such as the project ID, service account, and policy validation flag.
1.  `pool`: Specifies the build agent image to be used for running the pipeline tasks. In this case, the image is "ubuntu-latest", which is a frequently updated Ubuntu-based image.
1.  `stages`:
    -   `stage: auth`: The stage for GCP Workload Identity Federation (WIF) authentication. This stage contains a single job with multiple tasks.
        -   `job: governance_pipeline_azure`: The main job of the pipeline, with a 30-minute timeout. This job contains several tasks to be executed sequentially.
            1.  `task: TerraformInstaller`: Installs the latest version of Terraform, a tool for provisioning and managing infrastructure as code. Terraform will be used in later tasks to plan and apply changes to GCP resources.
            1.  `task: Get access token`: Retrieves an Azure access token for the service principal configured in the Azure Subscription. This token is exchanged for a GCP access token using Workload Identity Federation, which allows for seamless authentication across cloud providers. The GCP access token is then stored as an environment variable called `ACCESS_TOKEN`.
            1.  `task: Terraform plan`: Initializes Terraform in the specified working directory and runs a Terraform plan. This plan calculates the changes required to achieve the desired infrastructure state as defined in the Terraform configuration files. The plan is saved to a file called `test.tfplan`, and its JSON representation is written to `tfplan.json`.
            1.  `task: Policy Validate`: Validates the Terraform plan against a policy library, which contains rules and constraints for allowed infrastructure configurations. If any violations are detected, the pipeline will fail and not proceed to the next task. This step ensures that only compliant infrastructure changes are applied.
            1.  `task: Terraform apply`: Applies the Terraform plan if there are no policy violations. This step will create, update, or delete GCP resources as required to achieve the desired infrastructure state as defined in the Terraform configuration files.

This pipeline is designed to deploy GCP infrastructure using Terraform with Azure DevOps while incorporating authentication via Workload Identity Federation and policy enforcement through Google Cloud's Policy Library. The pipeline follows a series of steps, including authentication, Terraform initialization, planning, policy validation, and finally, applying the infrastructure changes if no policy violations are detected.

* CI/CD variables
    
    Add the variables to the pipeline as described in the table below. 

  
 ```
azureSubscription: "<service connection name between azure devops and gcp>"
projectID: "<gcp project>"
workloadIdentityPoolProvider: "<pool provider in gcp wif>"
Projectnumber: "<gcp project no>"
serviceaccount: "<sa in gcp>"
workloadIdentityPools: "<pool in gcp wif>"
policyValidate: "<true/false>"
``` 

### Terraform config validator
The pipeline has an option to utilise the integrated config validator (gcloud terraform vet) to impose constraints on your terraform configuration. You can enable it by setting the CI/CD Variable $TERRAFORM_POLICY_VALIDATE to "true" and providing the policy-library repo URL to $POLICY_LIBRARY_REPO variable. See the below for details on the Variables to be set on the CI/CD pipeline.



* Once the prerequisites are set up, trigger the pipeline manually or set the trigger as per your need. 


* gcp auth script should run successfully in the pipeline if the workload identity federation is configured as required.

### Pipeline Workflow Overview
 
  * Stages:
    * gcp-auth : creates the wif credentials by impersonating the service account.
    * terraform init : initializes terraform in the specified TF_ROOT directory
    * setup-terraform : Downloads the specified TF_VERSION and passes it as a binary to the next stages
    * validate: Runs terraform fmt check and terraform validate. This stage fails if the code is not run against terraform fmt command
    * plan: Runs terraform plan and saves the plan and json version of the plan as artifacts
    * policy-validate: Runs gcloud terraform vet against the terraform code with the constraints in the specified repository.
    * apply: once the plan is successful. 
             Runs terraform apply and  creates the infrastructure specified.

