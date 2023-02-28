This section covers CICD process using Gitlab and deploying resources to GCP.

Please look through the [README](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/README.md) for an overview of CICD process.


## How to Run this stage 
* Create a Group in gitlab
* Add project called “folder factory” and copy code from devops folder factory repo into it
* Add project called “project factory” and copy code from devops project factory repo into it
* Add a project called “skunkworks” and copy code from devops skunkworks repo into it.
* Workload Identity setup between the folder factory gitlab repositories and the GCP Identity provider configured with a service account containing required permissions to create folders and their organizational policies. 


* For further details on workload identity federation setup for Gitlab with GCP, please refer to the official Gitlab Documentation
* Available self hosted or SaaS Gitlab runners to run the pipelines.

