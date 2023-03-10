# Cloudbuild guardrail & pipeline example for individual workloads

To demonstrate how to enforce guardrails and pipelines for Google Cloud we provide the "Guardrail Examples". The purpose of these examples is demonstrate how to provision access & guardrails to new workloads with IaC. We provide you with the following 3 different components:

<img width="996" alt="Guardrail Examples" src="https://user-images.githubusercontent.com/94000358/224197342-95270909-49b2-43b4-acb3-fe01a5fe579b.png">

-   The [Folder Factory](folder-factory) creates folders and sets guardrails in the form of organisational policies on folders.

-   The [Project Factory](project-factory) sets up projects for teams. For this it creates a deployment service account, links this to a Github repository and defines the roles and permissions that the deployment service account has. 

The Folder Factory and the Project Factory are usually maintained centrally (by a cloud platform team) and used to manage the individual workloads. 

-   The [Skunkworks - IaC Kickstarter](skunkworks) is a template that can be used to give any new teams a functioning IaC deployment pipeline and repository structure.

This template is based on an "ideal" initial pipeline which is as follows:

![Cloud Build](https://user-images.githubusercontent.com/94000358/224201056-3331e1d9-d833-43ba-b322-1b11387f033a.png)

A video tutorial covering how to set up the guardrails for Github can be found here: https://www.youtube.com/watch?v=bbUNsjk6G7I

# Getting started

## Workload Identity federation 
Workload identity federation enables applications running outside of Google Cloud to replace long-lived service account keys with short-lived access tokens. 
This is achieved by configuring Google Cloud to trust an external identity provider, so applications can use the credentials issued by the external identity provider to impersonate a service account.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw

### High Level Process
* GCP
  - Create a Workload Identity Pool
  - Create a Workload Identity Provider
  - Create a Service Account and grant permissions
 
* CICD tool
  - Specify where the pipeline configuration file resides
  - Configure variables to pass relevant information to GCP to genrate short-lived tokens
