# DevOps Governance

A **CI/CD Approach & Framework** for infrastructure that can be used in governance heavy organizations and is intended to give the developers as much autonomy as possible to do their work following **DevOps & GitOps** principles.

![DevOps-Governance](https://user-images.githubusercontent.com/94000358/165718961-d794fa0e-7f0e-4b45-87e8-124e95ce692a.png)

The DevOps Governance framework is an **opinionated**  **developer centric approach to infrastructure CI/CD** with the **enterprise governance** taken into account.

In order to reduce friction in enterprise adoption it makes sense to look at the main stakeholders of a CI/CD system which are developers. The worst pain for developers is being blocked by bureaucratic processes and approvals. To create a certain level of agility in enterprise environments developers need to be enabled and autonomous as possible (DevOps principles).

One of these approaches to create this agility is to utilize a system like Gitlab or Github, which allows developers to define their pipelines in code and take ownership of their DevOps infrastructure pipelines. In enterprise environments we are however faced with regulations (NIST, ISO) and therefore need to also work with the security teams to make sure that we align on governance requirements.

By making use of Gitlab or Github (or any other tools that offer protected branches & pipeline as code), Workload Identity Federation, Gitflow we are able to cover the security teams requirements whilst at the same time giving the developers the required autonomy to do their work. 

DevOps governance will give infrastructure teams the required flexibility whilst still adhering to security requirements with “guardrails”.

## Guardrail & pipeline examples for individual workloads

To demonstrate how to enforce guardrails and pipelines for Google Cloud we provide the "Guardrail Examples". The purpose of these examples is demonstrate how to provision access & guardrails to new workloads with IaC. We provide you with the following 3 different components:

![Guardrail Examples](https://user-images.githubusercontent.com/94000358/169811919-e5c36181-c1d2-4339-8103-d86640e9a1f1.png)

-   The [Folder Factory](/examples/guardrails/github/folder-factory) creates folders and sets guardrails in the form of organisational policies on folders.

-   The [Project Factory](/examples/guardrails/github/project-factory) sets up projects for teams. For this it creates a deployment service account, links this to a Github repository and defines the roles and permissions that the deployment service account has. 

The Folder Factory and the Project Factory are usually maintained centrally (by a cloud platform team) and used to manage the individual workloads. 

-   The [Skunkworks - IaC Kickstarter](/examples/guardrails/github/skunkworks) is a template that can be used to give any new teams a functioning IaC deployment pipeline and repository structure.

A video tutorial covering how to set up the guardrails for Github can be found here: https://www.youtube.com/watch?v=bbUNsjk6G7I

The instructions above set out how to implement the Guardrail Examples for Github. We do however also provide support for other platforms:

## Supported Platforms

  - [Bitbucket](/examples/guardrails/bitbucket/README.md) 
  - [Cloudbuild](/examples/guardrails/cloudbuild/README.md) 
  - [Github](/examples/guardrails/github/README.md) 
  - [Gitlab](/examples/guardrails/gitlab/README.md) 
  - [Jenkins](/examples/guardrails/jenkins/README.md) 
  - [Terraform-Cloud](/examples/guardrails/terraform-cloud/README.md) 

## Workload Identity federation 
Workload identity federation enables applications running outside of Google Cloud to replace long-lived service account keys with short-lived access tokens. 
This is achieved by configuring Google Cloud to trust an external identity provider, so applications can use the credentials issued by the external identity provider to impersonate a service account.

If you do require additional assitance to setup Workload Identity Federation have a look at: https://www.youtube.com/watch?v=BuyoENMmtVw

### High Level Process
* GCP
  - Create a Workload Identity Pool
  - Create a Workload Identity Provider
  - Create a Service Account and grant permissions
 
* CICD tool
  - Specify where the pipeline configuration file resides
  - Configure variables to pass relevant information to GCP to genrate short-lived tokens

examples/guardrails section covers different CICD tools and how to leverage Workload Identity Federation between each tool and Google Cloud. 

## Disclaimer

This is not an officially supported Google product.
