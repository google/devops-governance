# Getting started

This workflow covers the steps to setup ADO (azuredevops) CICD pipeline for terraform. The setup involves setting up ADO  repository and the corresponding CI/CD settings and variables. The pipeline triggers based on select events (like push to specific branches), authenticates to the specified service account using Workload Identity federation and runs the pipeline to deploy infrastructure using terraform in GCP.\
A more comprehensive description of DevOps & GitOps principles can be found at [DevOps README](https://github.com/google/devops-governance/blob/GDC-phase-kickstarter-1/README.md).

## Implementation Process

The setup consists of configuring folder-factory, project-factory and skunkworks as three ADO repositories. The pre-requisites and the setup are detailed below for each of the repositories.

Workload identity federation enables applications running outside of Google Cloud to replace long-lived service account keys with short-lived access tokens. This is achieved by configuring Google Cloud to trust an external identity provider, so applications can use the credentials issued by the external identity provider to impersonate a service account.\
To use Azure Devops with GCP Deployments, we can leverage on [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) between Azure Devops and Google Cloud. This will be possible by configuring the Workload Identity Federation to trust OIDC tokens generated for a specific workflow in Azure Devops.

## ADO Prerequisites

-   Create a Project in ADO
-   Add a repo called "folder factory" and copy code from [devops folder factory repo](../../../examples/guardrails/azuredevops/folder-factory) into it
-   Add repo called "project factory" and copy code from [devops project factory repo](../../../examples/guardrails/azuredevops/project-factory) into it
-   Add a repo called "skunkworks" and copy code from [devops skunkworks repo](../../../examples/guardrails/azuredevops/skunkworks) into it.

> .\
Once ADO set is completed go to [Folder Factory](../../../examples/guardrails/azuredevops/folder-factory)
