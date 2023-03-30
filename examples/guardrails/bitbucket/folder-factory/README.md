# Folder Factory
--------------

folder-factory will deploy the folders and establish the organizational hierarchy. Inside the repo is a subdirectory of data/folders that contain yaml files. Each yaml file contains a new folder definition.

## Deployment:

#### Authentication

folder-factory should be deployed outside of the normal pipeline process. Workload Identity Federation, which will authorize bitbucket pipelines to communicate with GCP, will not be configured until after the project-factory is deployed.

Since this is being deployed outside of the pipeline environment, authentication will need to be established separately. If running locally, this can be done with:

```
gcloud  auth  login
```

Alternatively, CloudShell can be used for an easy environment that is already GCP authenticated.

The authenticated user should have permissions in GCP IAM to create folders. If desired, a Service Account may be used that has the required permissions. See [Impersonating Service Accounts](https://cloud.google.com/iam/docs/impersonating-service-accounts) for more information.

#### Terraform

After authentication, the terraform can be deployed. Navigate to the root of the folder-factory repository and initialize the terraform.

```
cd  folder-factory
```

Before Terraform can be initialized, Terraform needs to be directed on where to store the state file within Google Cloud Storage. Open the file named providers.tf and populate values for bucket and prefix. The modified file should resemble the following:

```
terraform  {
  backend  "gcs"  {
    bucket  =  "your-bucket-name"
    prefix  =  "path/to/state/file/"
  }
}
#  ...
```

After this change is made, Terraform can be initialized.

```
terraform  init
```

This is when to add, change, or modify any of the yaml files in the data/folders directory. See sample yaml provided for details. Each yaml file contains the definition of a new GCP folder.

Upon making any modifications, run the following to plan the deployment.

```
terraform  plan
```

After reviewing the proposed infrastructure changes, approve the deployment.

```
terraform  apply  -auto-approve
```

Folders should now be deployed into your GCP environment