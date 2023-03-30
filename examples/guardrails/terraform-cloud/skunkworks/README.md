
# Skunkworks - IaC Kickstarter Template

This is a template for an IaC kickstarter repository.

![Skunkworks](https://user-images.githubusercontent.com/94000358/169810982-36f01de2-e5e5-4ecd-b98e-3cf5a6aa9f81.png)

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github. 

This template will use the project and service account created in project factory to deploy reosurces for Skunkworks.

## Repository Configuration
This repository does not need any additional runners (uses Github runners) and does require you to previously setup Workload Identity Federation to authenticate.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw


- Ensure to have a Workspace created on terraform Cloud which would have Gitlab Repository as the VCS Source

- Outputs of Project Factory, will give the variable values for below variables, and the same has to be updated on the terraform workspace

```
env:
  impersonate_service_account_email: 'xxx@project.iam.gserviceaccount.com'
  # The Service Account used to create Folder

  project: 'xxxx'
  # Project in which resource will be created

  TFC_WORKLOAD_IDENTITY_AUDIENCE: '//iam.googleapis.com/projects/id/locations/global/workloadIdentityPools/<poolname>/providers/<providername>'
  # WorkLoad Identity Audience will be used by tfc-oidc module for token generation and impersonation 
```


> **_NOTE:_** You can create multiple branches to control the Skunkworks deployment workflow. You can upadte the Terraform Workspace below Settings
>  - Terraform Working Directory
>  - VCS Branch 