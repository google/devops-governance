# Folder Factory

This is a template for a DevOps folder factory.

It can be used with [https://github.com/google/devops-governance/tree/main/examples/guardrails/github/project-factory](https://github.com/google/devops-governance/tree/main/examples/guardrails/github/project-factory) and is intended to house the folder configurations:

<img width="1018" alt="Screenshot 2023-03-10 at 03 08 41" src="https://user-images.githubusercontent.com/94000358/224205959-bdac40d9-90f3-409a-a52f-e006714f2c8f.png">

Using Keyless Authentication the project factory connects a defined Github repository with a target service account and project within GCP for IaC.

The idea is to enable developers of the "skunkworks" repository to deploy into the "skunkworks" project via IaC pipelines on Github.

## Repository Configuration
This repository does not need any additional runners (uses Github runners) and does require you to previously setup Workload Identity Federation to authenticate.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw

After setting up WIF you can then go ahead and configure this repository. This can be done by either with setting the following secrets:

<img width="787" alt="Secret configuration" src="https://user-images.githubusercontent.com/94000358/161538148-5b5a5047-b512-4d5a-9a95-912eb4f8a138.png">

or by modifing the [Workflow Action](.github/workflows/terraform-deployment.yml) and setting the environment variables:
```
env:
  STATE_BUCKET: 'XXXX'
  # The GCS bucket to store the terraform state 
  WORKLOAD_IDENTITY_PROVIDER: 'projects/XXXX'
  # The workload identity provider that should be used for this repository.
  SERVICE_ACCOUNT: 'XXXX@XXXX'
  # The service account that should be used for this repository.
```

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
