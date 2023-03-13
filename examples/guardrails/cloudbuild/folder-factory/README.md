# Folder Factory

The folder factory will:
- create folder(s) with defined organization policies

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

> Detailed instructions of CloudBuild trigger setup can be found at [README](./../../../README.md).
