# Project Factory

This is a template for a DevOps project factory.

It can be used with https://github.com/google/devops-governance/tree/main/examples/guardrails/gitlab/folder-factory (https://github.com/google/devops-governance/tree/main/examples/guardrails/gitlab/folder-factory) and is intended to house the projects of a specified folder:

<img width="1466" alt="Overview" src="https://user-images.githubusercontent.com/94000358/161531177-23a99468-1e7b-4583-a243-624ee4663506.png">

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

<img width="1007" alt="Screenshot 2023-03-10 at 02 53 10" src="https://user-images.githubusercontent.com/94000358/224204533-36846466-5567-43ac-b81e-4bf75f2520b6.png">

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
repo_provider: gitlab
repo_name: devops-governance/skunkworks
repo_branch: dev
```

Every project is defined with its own file located in the [Project Folder](data/projects).

## How to run this stage

### Prerequisites 
The parent folders are provisioned to place the projects.


Workload Identity setup between the project factory repositories and the GCP Identity provider configured with a service account containing required permissions to create projects, workload identity pools and providers, service accounts and IAM bindings on the service accounts under the parent folder in which the projects are to be created.
“Project Creator” should already be granted when running the folder factory.
“Billing User” on Billing Account

### Installation Steps
From the project-factory  repo
CICD configuration file path 
Navigate to the azure-pipeline.yml file 

This is a YAML file for Azure DevOps that sets up a CI/CD pipeline for deploying infrastructure changes to Google Cloud Platform (GCP) using Terraform. It leverages Workload Identity Federation for authentication and integrates with Google Cloud's Policy Library for enforcing infrastructure policies. Let me break down the pipeline components:

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

Similar to Folder factory, 

Once the prerequisites are set up, manually trigger the pipeline.  

gcp auth script should run successfully in the pipeline if the workload identity federation is configured as required.

### Pipeline Workflow Overview

* Stages:
  * gcp-auth : creates the wif credentials by impersonating the service account.
  * terraform init : initializes terraform in the specified TF_ROOT directory
  * setup-terraform : Downloads the specified TF_VERSION and passes it as a binary to the next stages
  * validate: Runs terraform fmt check and terraform validate. This stage fails if the code is not run against terraform fmt command
  * plan: Runs terraform plan and saves the plan and json version of the plan as artifacts
  * policy-validate: Runs gcloud terraform vet against the terraform code with the constraints in the specified repository.
  * apply:  once the plan is successful. 
          Runs terraform apply and creates the infrastructure specified.