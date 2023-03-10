# Gitlab guardrail & pipeline example for individual workloads

To demonstrate how to enforce guardrails and pipelines for Google Cloud we provide the "Guardrail Examples". The purpose of these examples is demonstrate how to provision access & guardrails to new workloads with IaC. We provide you with the following 3 different components:

<img width="1003" alt="Gitlab" src="https://user-images.githubusercontent.com/94000358/224200491-2e1b841a-6baa-481f-8a17-acb29e3a00cd.png">

-   The [Folder Factory](folder-factory) creates folders and sets guardrails in the form of organisational policies on folders.

-   The [Project Factory](project-factory) sets up projects for teams. For this it creates a deployment service account, links this to a Github repository and defines the roles and permissions that the deployment service account has. 

The Folder Factory and the Project Factory are usually maintained centrally (by a cloud platform team) and used to manage the individual workloads. 

-   The [Skunkworks - IaC Kickstarter](skunkworks) is a template that can be used to give any new teams a functioning IaC deployment pipeline and repository structure.

This template is based on an "ideal" initial pipeline which is as follows:

![Ideal Pipeline Generic](https://user-images.githubusercontent.com/94000358/224196745-4ce7e761-82d4-4eba-b0b2-2912ca73eccb.png)

A video tutorial covering how to set up the guardrails for Github can be found here: https://www.youtube.com/watch?v=bbUNsjk6G7I

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



