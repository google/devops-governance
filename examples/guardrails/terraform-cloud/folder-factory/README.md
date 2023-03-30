# Folder Factory

This is a template for a DevOps folder factory.

It can be used with [https://github.com/google/devops-governance/tree/main/examples/guardrails/project-factory](https://github.com/google/devops-governance/tree/main/examples/guardrails/project-factory) and is intended to house the folder configurations:

![Screenshot 2022-05-10 12 00 19 PM](https://user-images.githubusercontent.com/94000358/169809437-aaa8538e-3ffc-48b3-9028-84e4995de150.png)

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github.

## Repository Configuration
This repository does not need any additional runners (uses Github runners) and does require you to previously setup Workload Identity Federation to authenticate.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw

## Setting Up Terraform Wokspace on Terraform Cloud


- Ensure to have a Workspace created on terraform Cloud which would have Gitlab Repository as the VCS Source.

- Update the [data](data/folders/) with pre created organisation ID and Service account.

- Update the variables for Terraform Workspace as below

```
env:
  impersonate_service_account_email: 'xxx@project.iam.gserviceaccount.com'
  # The Service Account used to create Folder.
  project_id: 'xxxx'
  # Project ID which will host provider aand pool
  TFC_WORKLOAD_IDENTITY_AUDIENCE: '//iam.googleapis.com/projects/id/locations/global/workloadIdentityPools/<poolname>/providers/<providername>'
  # WorkLoad Identity Audience will be used by tfc-oidc module for token generation and impersonation 
```


> **_NOTE:_** You need to have TFC Workspace ID & TFC Organisation ID created, before it can be passed in [terraform-cloud-wif](terraform-cloud-wif) module to generate the Provider, Pool, Service account & IAM Role. This IAM Role would be attached to the Service Account allowing authorization.

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
