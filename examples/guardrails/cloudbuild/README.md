# Cloudbuild guardrail & pipeline example for individual workloads

To demonstrate how to enforce guardrails and pipelines for Google Cloud we provide the "Guardrail Examples". The purpose of these examples is demonstrate how to provision access & guardrails to new workloads with IaC. 

> A more comprehensive description of DevOps & GitOps principles can be found at DevOps README.


### Implementation Process
Gitlab repository can be build with Cloud build by webhook triggers. Following are the steps to setup webhooks triggers to build repository from gitlab:

### Prerequisites
Enable the Cloud Build and secret manager API
Create a GCS bucket to store the terraform state file. Note: The bucket name will be configured as a cloud build variable substitutions while creating the cloud build trigger.
Gitlab repository with Folder Factory, Project Factory and Skunkworks Terraform code.
Note: SSH access on the gitlab repository should be given to allow users on the server to add their own ssh keys and use those ssh keys to secure git operations between their computer and gitlab instance. 

