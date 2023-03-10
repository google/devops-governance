# Project Factory

This is a template for a DevOps project factory.

It can be used with https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory (https://github.com/google/devops-governance/tree/main/examples/guardrails/folder-factory) and is intended to house the projects of a specified folder:

<img width="1466" alt="Overview" src="https://user-images.githubusercontent.com/94000358/161531177-23a99468-1e7b-4583-a243-624ee4663506.png">

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

<img width="1019" alt="Screenshot 2023-03-10 at 03 09 10" src="https://user-images.githubusercontent.com/94000358/224207311-5317f79c-fdb3-4eb3-97b7-9600c9469c49.png">

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github.

## Repository Configuration
This repository does not need any additional runners (uses Github runners) and does require you to previously setup Workload Identity Federation to authenticate.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw

After setting up WIF you can then go ahead and configure this repository. This can be done by either with setting the following secrets:

<img width="785" alt="Secret settings" src="https://user-images.githubusercontent.com/94000358/161528557-41446670-1e3b-4ea1-996d-e377e53d9c43.png">

or by modifing the [Workflow Action](.github/workflows/terraform-deployment.yml) and setting the environment variables:
```
env:
  STATE_BUCKET: 'XXXX'
  # The GCS bucket to store the terraform state 
  FOLDER: 'folders/XXXX'
  # The folder under which the projects should be created
  WORKLOAD_IDENTITY_PROVIDER: 'projects/XXXX'
  # The workload identity provider that should be used for this repository.
  SERVICE_ACCOUNT: 'XXXX@XXXX'
  # The service account that should be used for this repository.
```

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
repo_provider: github
repo_name: devops-governance/skunkworks
repo_branch: dev
```

Every project is defined with its own file located in the [Project Folder](data/projects).
