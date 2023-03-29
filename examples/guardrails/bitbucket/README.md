# Bitbucket guardrail & pipeline example for individual workloads

To demonstrate how to enforce guardrails and pipelines for Google Cloud we provide the "Guardrail Examples". The purpose of these examples is demonstrate how to provision access & guardrails to new workloads with IaC. We provide you with the following 3 different components:

<img width="995" alt="Bitbucket" src="https://user-images.githubusercontent.com/94000358/224200094-66832176-3759-4555-b6cd-efc970d5a556.png">

-   The [Folder Factory](folder-factory) creates folders and sets guardrails in the form of organisational policies on folders.

-   The [Project Factory](project-factory) sets up projects for teams. For this it creates a deployment service account, links this to a Github repository and defines the roles and permissions that the deployment service account has. 

The Folder Factory and the Project Factory are usually maintained centrally (by a cloud platform team) and used to manage the individual workloads. 

-   The [Skunkworks - IaC Kickstarter](skunkworks) is a template that can be used to give any new teams a functioning IaC deployment pipeline and repository structure.

This template is based on an "ideal" initial pipeline which is as follows:

![Ideal Pipeline Generic](https://user-images.githubusercontent.com/94000358/224196745-4ce7e761-82d4-4eba-b0b2-2912ca73eccb.png)

A video tutorial covering how to set up the guardrails for Github can be found here: https://www.youtube.com/watch?v=bbUNsjk6G7I

# Getting started

## Overview
This Runbook contains three repositories; project-factory, folder-factory, and skunkworks. The first two of these repositories do not need to be deployed inside of a traditional bitbucket pipeline. They will deploy the necessary components to establish a structure within GCP and set up a Workload Identity Federation (WIF) provider. The third repository, skunkworks, has an example bitbucket pipeline that will authenticate via the established WIF provider. 

### High Level Process
  - **Deploy Folder Factory**
      - Enter the Folder Factory directory
      - Edit provider.tf to contain a backend. Using gcs is suggested by referencing an existing GCS bucket. Use the prefix variable to ensure folder-factory's state exist in a directory within the bucket.
      - Add folder yaml files to /data/folders.
      - Deploy via Terraform
  - **Deploy Project Factory**
      - Enter the Project Factory directory
      - Edit provider.tf to contain a backend. Using gcs is suggested by referencing an existing GCS bucket. Use the prefix variable to ensure project-factory's state exist in a directory within the bucket.
      - Within terraform.tfvars add the proper variables for folder (created with Folder Factory), billing account, Bitbucker Workspace, and allowed Audiences. If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw
      - Add project yaml files to /data/projects.
      - Deploy via Terraform
  - **Deploy Skunkworks**
      - Enter the Skunkworks directory
      - Edit provider.tf to contain a backend. Using gcs is suggested by referencing an existing GCS bucket. Use the prefix variable to ensure skunkworks' state exist in a directory within the bucket.
      - Within terraform.tfvars add the proper variables for the project created in Project Factory
      - Within the Bitbucket repository variables, add all the variables described within the Skunkworks README.md.
      - Deploy Skunkworks via Bitbucket Pipeline. The pipeline will authenticate to GCP using the Workload Identity Pool created within Project Factory
