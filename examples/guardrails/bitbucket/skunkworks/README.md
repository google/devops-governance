# Skunkworks - Bitbucket Pipelines Terraform Example with Workload Identity Federation

This is a template for an IaC Terraform repository that includes a Bitbucket pipeline that authenticates via Workload Identity Federation. It is intended to be run after folder-factory and project-factory.

![Skunkworks](https://user-images.githubusercontent.com/94000358/169810982-36f01de2-e5e5-4ecd-b98e-3cf5a6aa9f81.png)



This is simple repository that only deploys a GCS bucket into a specified project. The point of this project is to prove that Terraform can be deployed to Bitbucket via Workload Identity Federation. 

## Repository Configuration

1. Clone this repository and push it to your own Bitbucket repository.
1. Enable pipelines in your Bitbucket Repository. This is done in **Repository Settings** > **Pipelines** > **Settings**.
2. Set up the required environment variables in your Bitbucket repository settings. This is done in **Repository Settings** > **Pipelines** > **Repository variables**.

   | Environment Variable            | Description                                                                       | Example Value                                               |
   |---------------------------------|-----------------------------------------------------------------------------------|-------------------------------------------------------------|
   | `TERRAFORM_VERSION`             | The version of Terraform you want to use                                          | `1.4.2`                                                   |
   | `STATE_BUCKET`                   | The Google Cloud Storage bucket where your Terraform state files will be stored | `my-terraform-state-bucket`                              |
   | `GCP_WORKLOAD_IDENTITY_PROVIDER`| The fully qualified identifier of your Google Cloud Workload Identity Provider *(See **project-factory** outputs)* | `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID` |
   | `GCP_SERVICE_ACCOUNT`           | The email address of your Google Cloud Service Account *(See **project-factory** outputs)* | `my-service-account@my-project.iam.gserviceaccount.com` |
   | `PROJECT_NAME`                  | Your Google Cloud project ID *(See **project-factory** outputs)* | `my-gcp-project`                                             |
   | `TERRAFORM_POLICY_VALIDATE`     |  | `true`|
1. add a `terraform.tfvars` that specifies the project you want the bucket to be created in
    ```hcl
    project = "my-gcp-project"
    ```
1. Commit to your repository to trigger a build

