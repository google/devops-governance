# Project Factory

This repo will deploy new projects and the necessary resources to use  Workload Identity Federation with Bitbucket. Inside the repo is a subdirectory structure `data/projects` that contain yaml files. Each yaml file contains the definition of a new project. Each project deployed will also create a new Workload Identity Pool and provider. The created pool ID and provider are included in the terraform outputs.

This repo is intend to be deployed manually.

## Deployment 

### Authentication

project-factory should be deployed outside of the normal pipeline process. Workload Identity Federation, which will authorize Bitbucket pipelines to communicate with GCP, will not be configured until after this repository is fully deployed.

Since this is being deployed outside of the pipeline environment, authentication will need to be established separately. If deploying locally, this can be done with

```bash
gcloud auth login
```

Alternatively, [CloudShell](https://cloud.google.com/shell) can be used for an easy environment that is already GCP authenticated.

The user who is authenticated should have permissions in GCP IAM to create projects and attach them to the correct billing account. Additionally, the user needs the permissions to create and manage Workload Identity Federation pools and providers. If desired, a Service Account may be used that has the required permissions. See [Impersonating Service Accounts](https://cloud.google.com/iam/docs/impersonating-service-accounts) for more information.


### Terraform 

After authentication, the Terraform can be deployed. Navigate to the root of the project-factory repository.

```bash
cd project-factory
```

Before Terraform can be initialized, Terraform needs to be directed on where to store the state file within Google Cloud Storage. Open the file named `providers.tf` and populate values for bucket and prefix. The modified file should resemble the following:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-bucket-name"
    prefix = "path/to/state/file/"
  }
}

# ...
```

The bucket value should be the name of a bucket already in GCP. The prefix value is optional, but can be used to define a directory structure within the bucket to store the state file.

After this change is made, Terraform can be initialized.

```bash
terraform init
```

Here is where you would want to add, change, or modify any of the yaml files in the `data/projects` directory. For more information, see the sample yaml provided. Each yaml file contains the definition of a new GCP project.

Before the Terraform can be applied, there is one more section that will require information. In the root of the project-factory repo there must exist a file named terraform.tfvars. This is where variables need to be populated that apply to all projects. The following values need to be provided:

| Variable | Description | Example Value |
|-|-|-|
|`folder`|Folder ID of where to deploy the project |`"folders/98765432101"`|
|`folder`|GCP billing account to attach projects to = |`"018888-01888-ABC123"`|
|`folder`|Name of workspace in Bitbucket |`"bbworkspace"`|
|`folder`|List of audience tokens provided by Bitbucket. See below for additional details. |`["ari:cloud:bitbucket::workspace/000000ee-1111-11ae-bbbb-1111aeeee111"]`|

#### `allowed_audiences` Value

The audience token ensures Bitbucket pipelines are allowed to authenticate via Workload Identity. Its value can be retrieved after creating a repository. It is important to note that the “audience” value is tied to the Bitbucket Workspace, meaning all repos in the same Bitbucket workspace will have the same audience value.  If an organization uses multiple workspaces, the audience value will need to be retrieved for each.

For the purposes of this example, we will create a repo in Bitbucket “skunkworks” that will later be populated with terraform. 

In bitbucket, create the new repository. Aftwards, Bitbucket pipelines will need to be enabled. Go to the repository settings and look for **Pipelines** > **Settings** and check **Enable Pipelines**. 

Next, navigate to **Pipelines** > **OpenID Connect**. This screen will contain a value, **Audience**, which we will need to copy. The value in Audience needs to be included in our list within `terraform.tfvars`.

A complete `terraform.tfvars` should resemble the following:

```hcl
folder = "folders/00000012345"

billing_account = "018888-01888-ABC123"

workspace = "bbworkspace"

allowed_audiences = ["ari:cloud:bitbucket::workspace/000000ee-1111-11ae-bbbb-1111aeeee111", "ari:cloud:bitbucket::workspace/000000ee-2222-11ae-bbbb-2222affff111"]
```

Upon making any modifications, run the following in the root of the repo to plan the deployment.

```bash
terraform plan
```
After reviewing the proposed infrastructure changes, approve the deployment.
```bash
terraform apply -auto-approve
```

