# Project Factory

This is a template for a DevOps project factory.

It can be used with https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory (https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory) and is intended to house the projects of a specified folder:

<img width="1466" alt="Overview" src="https://user-images.githubusercontent.com/94000358/161531177-23a99468-1e7b-4583-a243-624ee4663506.png">

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

![Folder Factory](https://user-images.githubusercontent.com/94000358/169809882-f5ff9fb1-d037-49de-8c2c-bf0d457b662f.png)

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github.

## Repository Configuration
This repository does not need any additional runners (uses Github runners) and does require you to previously setup Workload Identity Federation to authenticate.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw

## Setting Up Terraform Wokspace on Terraform Cloud

Ensure to have a Workspace created on terraform Cloud which would have Gitlab Repository as the VCS Source

Update the variables for Terraform Workspace as below

```
env:
  impersonate_service_account_email: 'xxx@project.iam.gserviceaccount.com'
  # The Service Account used to create Folder

  folder: 'xxxx'
  # Folder under which Projects will be created

  TFC_WORKLOAD_IDENTITY_AUDIENCE: '//iam.googleapis.com/projects/id/locations/global/workloadIdentityPools/<poolname>/providers/<providername>'
  # WorkLoad Identity Audience will be used by tfc-oidc module for token generation and impersonation 
```


> **_NOTE:_** You need to have TFC Workspace ID created manually, before it can be passed in terraform-cloud-wif module under Folder Factory to generate the Provider, Pool Service account and IAM Role attached to the role.

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
tfe_workspace_id: ws-xxxx
```

Every project is defined with its own file located in the [Project Folder](data/projects). 

> **_NOTE:_** You can also manage the environments seprately via a diffrent Gitlab Branches for each Environment Which and having environment specific file under [Project Folder](data/projects). These branches can be tied to individual workspace.