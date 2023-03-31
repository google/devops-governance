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
