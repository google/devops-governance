# Github guardrail & pipeline example for individual workloads

To demonstrate how to enforce guardrails and pipelines for Google Cloud we provide the "Guardrail Examples". The purpose of these examples is demonstrate how to provision access & guardrails to new workloads with IaC. We provide you with the following 3 different components:

<img width="1001" alt="Github" src="https://user-images.githubusercontent.com/94000358/224200201-8ae02049-4fdb-46a1-9bb0-b44bada38172.png">

-   The [Folder Factory](folder-factory) creates folders and sets guardrails in the form of organisational policies on folders.

-   The [Project Factory](project-factory) sets up projects for teams. For this it creates a deployment service account, links this to a Github repository and defines the roles and permissions that the deployment service account has. 

The Folder Factory and the Project Factory are usually maintained centrally (by a cloud platform team) and used to manage the individual workloads. 

-   The [Skunkworks - IaC Kickstarter](skunkworks) is a template that can be used to give any new teams a functioning IaC deployment pipeline and repository structure.

This template is based on an "ideal" initial pipeline which is as follows:

![Ideal Pipeline Github](https://user-images.githubusercontent.com/94000358/224200939-94df478c-cae5-41b3-bf0d-ed573da331f3.png)

A video tutorial covering how to set up the guardrails for Github can be found here: https://www.youtube.com/watch?v=bbUNsjk6G7I

# Getting started

Deployment and configuration information can be found on the following pages:

- [Folder Factory](folder-factory)
- [Project Factory](project-factory)
- [Skunkworks - IaC Kickstarter](skunkworks)
