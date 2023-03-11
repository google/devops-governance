> A more comprehensive description of DevOps & GitOps principles can be found at [DevOps README](./../README.md). The module adopts the same principles and details instructions for Gitlab.

# Getting started

This workflow covers the steps to setup gitlab CICD pipeline for terraform with gitlab SaaS shared runners.
The setup involves setting up gitlab repository and the corresponding CI/CD settings and variables. 
The pipeline triggers based on select events (like push to specific branches), authenticates to the specified service account using Workload Identity federation and runs the pipeline to deploy infrastructure using terraform in GCP. 
Please look through the [README](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/README.md) for an overview of the CICD process.

## Implementation Process

The setup consists of configuring folder-factory, project-factory and skunkworks as three gitlab repositories. The pre-requisites and the setup are detailed below for each of the repositories.

Workload Identity federation is a keyless authentication mechanism that is an important component of the CICD setup as it securely allows us to authenticate gitlab on GCP. It connects a defined Gitlab repository with a target service account and project within GCP for IaC.

The actual implementation for granting impersonation access on the service account to the WIF provider identity depends on your desired configuration. You can choose to let the service account be impersonated only from changes by a specific gitlab user or a specific gitlab project or a combination of project and a branch..etc. For further details on workload identity federation setup for Gitlab with GCP, please refer to the official [Gitlab Documentation](https://docs.gitlab.com/ee/ci/cloud_services/google_cloud/)


## Gitlab Prerequisites
* Create a Group in gitlab
* Add project called “folder factory” and copy code from [devops folder factory repo](https://github.com/google/devops-governance/tree/GDC-phase-kickstarter-1/examples/guardrails/gitlab/folder-factory) into it
* Add project called “project factory” and copy code from [devops project factory repo](https://github.com/google/devops-governance/tree/GDC-phase-kickstarter-1/examples/guardrails/gitlab/project-factory) into it
* Add a project called “skunkworks” and copy code from [devops skunkworks repo](https://github.com/google/devops-governance/tree/GDC-phase-kickstarter-1/examples/guardrails/gitlab/skunkworks) into it.
* Available self hosted or SaaS Gitlab runners for each of the gitlab projects to run the pipelines.

Once Gitlab set is completed go to [Folder Factory](./folder-factory)



