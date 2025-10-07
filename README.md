# Azure AKS Sample App Environment — End-to-End Deployment & Monitoring

##  Objective
The objective of this project is to **provision a production-grade Azure Kubernetes Service (AKS)** environment for a sample web application.(This app use a simple node js app expose four end points "/ping","/current-date","/fibo/","/metrics)

The setup ensures:
- Secure and modular infrastructure provisioning using **Terraform**
- PR **Validation** pipeline for validating application and infra changes before merge.
- **Continuous Integration/Deployment (CI/CD)** using Github Actions
- Linting kubernetes manifest using kube-linter
- Kubernetes deployments through Kustomize
- **Security scanning** of Infrastructure as Code (IaC) using **Checkov**
- **End-to-end monitoring** using **Prometheus** and **Grafana** using Helm
---

## Architecture Overview

### Components
| Layer | Services / Tools | Purpose |
|-------|------------------|----------|
| **Infrastructure** | Terraform | IaC for Azure resources |
| **Container Registry** | Azure Container Registry (ACR) | Stores Docker images |
| **Compute & Orchestration** | Azure Kubernetes Service (AKS) | Runs application workloads |
| **Networking** | Azure Virtual Network, Subnets, NSGs | Secure network segmentation |
| **Security** | RBAC, Key Vault, Image Cleaner, Pod SecurityContext | Enforces access & runtime security |
| **Autoscaling** | KEDA | Event-driven pod autoscaling |
| **Monitoring** | Prometheus & Grafana | Observability and performance dashboards |
| **CI/CD** | Github Actions | Automates build and deploy |
| **IaC Security** | Checkov  | Validates Terraform code compliance |
---

## Infrastructure Provisioning

Assumptions: 
1. Storage account for storing state file is not included in the code but provisioned seperately. For real enviornment setup storage account should be created with network rules, Blob versioning and retention policy
2. NSG rules are with default rules. For access to cluster we need to add the rules as per the requirement
3. Application should integrate with Key vault for secret management. CSI secret driver is already enabled through code.
4. Application shoudd integrate with Azure App Config store to store application settings and environment values
5. Neccessary RBAC groups and Custom roles should be created for Azure RBAC integration with AKS
6. All workload should use workload federated identity (OIDC) to connect to azure resources rather than using client secrets
7. Required azure policies and initiatives should be created and assigned to the cluster resource group
8. For container insights/logs enable container insights and send the container logs to log anayltics workspace. Also use DCR with transformation to filter the logs to save the cost
9. As automate upgrade is enable create a maintenance window for cluster and node image upgrade
10. To avoid multiple repo terraform modules are kept under the same repo with application code. For real case use different repo to keep terraform reusable modules
11. Custom Keda Object and Trigger authentication CRD should be deployed to use KEDA scaling for prometheus or other sources

### Repository Structure
```
├── infrastructure/
│ ├── main.tf
│ ├── backend.tf
│ ├── providers.tf
│ ├── variables.tf
│ ├── outputs.tf
│ ├── modules/
│ │ ├── network/
│ │ ├── acr/
│ │ ├── aks/
│ │ ├── keyvault/
│ │ └── monitor/
│ └── .github/workflow
```

### Terraform Modules
| Module | Description | Best Practices Implemented |
|---------|--------------|-----------------------------|
| **Network** | Creates Virtual Network, Subnets, NSGs | Network isolation, Private subnets |
| **ACR** | Creates Azure Container Registry | Admin disabled, RBAC-integrated |
| **AKS** | Provisions cluster | RBAC enabled, AAD integration, Network Policy, Key Vault CSI Driver, KEDA, Image Cleaner |
| **Key Vault** | Stores secrets securely | Access controlled via Managed Identity |
| **Monitor** | Deploys Prometheus & Grafana via Helm | Namespace isolation, persistent storage |

### Security Enhancements

1. **RBAC**: AKS is deployed with Microsoft Entra ID authentication with Azure RBAC so that we can use and leverage existing AD groups and provide Single access model for all Azure resources. This will also provide Conditional Access, MFA Support and Centralized Auditing and Logging. We can builtin roles like Azure Kubernetes Service RBAC Reader, Azure Kubernetes Service RBAC Writer, Azure Kubernetes Service RBAC Admin, Azure Kubernetes Service RBAC Cluster Admin and Custom roles
2. **Workload Identity and OIDC**: Enabled Azure AD Workload Identity integration for the cluster. It allows Kubernetes service accounts (with annotations) to federate with Azure AD identities (User-Assigned Managed Identities). While enabling the OpenID Connect (OIDC) Issuer endpoint for the AKS cluster exposes a secure, managed OIDC token endpoint that Kubernetes uses to issue identity tokens for workloads.
3. **Azure policy add on**: When Azure Policy integration is enabled, the AKS cluster periodically checks with the Azure Policy service for any policy assignments applied to it. The service then deploys the corresponding policy definitions into the cluster as ConstraintTemplate allowing in-cluster enforcement and auditing of compliance rules.
4. **Image Cleaner**: To automatically detects and removes unused vulnerable container images from nodes in the cluster.
5.  **Managed Identities** for accessing other azure resources like Key vault, ACR
6.  **Key Vault CSI driver** for secret injection in pods
7. **Node pools**: Two node pool are added for system and user workloads
8. **OS Disk type** used is Ephemeral for faster auto scale operations
9. **Automatic Upgrade** set as stable

 Further enhancements: For additional security we can enable **Istio service mesh** for MTLS authentication between service to service communication or **Cilium data plane** for Network policy

---

## Terraform Scanning using Checkov

Terraform validation and Checkov scanning is integrated into Infra-Validation workflow with infra-gated-validation.yaml file. This workflow is triggered based on PR request so that if any checks failed will block the PR to merge with main branch keeping main branch secure and error free. This workflow checks for Terraform validate, checkov scans and terraform plan

<img width="2283" height="1617" alt="image" src="https://github.com/user-attachments/assets/d4d7f2ad-4c0b-4752-8796-2936289c0916" />

Note: Failed ones where of LOW severity, and --soft-fail was provided intentionally to continue with workflow execution.

---

## Terraform Deployment
Infra deployment is seperated out of application deployment as change frequency will be less for infra than application. Terraform deployment worflow is Infra-Deploy with infra-deployment.yaml file and terraform apply is part of this workflow

AKS Cluster in Azure Portal
<img width="3195" height="447" alt="image" src="https://github.com/user-attachments/assets/88e76c27-e6bc-4b2e-885f-a965fbbcb723" />


## Application Deployment

### App Setup
A sample node js app was containerized and pushed to ACR via the CI/CD pipeline. Workflow application-deployment-cicd.yaml is used for application deployment This workflow deals with building the docker app and pushing to ACR as build job. Also it has a deployment job to authenticate to azure, setting the manifest and deploy using kubcectl. Pipeline also checks the rollout status and if rollout failed rollback happens automatically by explicitly failing the task to monitor the failure

Application also has a PR validation workflow (hello-node-gated.yaml) which docker build the app, linting kubernetes yaml using kube-lint and kubecl diff for validation before PR merge. In addition we can also use Sonarqube and Trivy scan for static code and docker image analysing. (Not implemented)

Kubernetes yaml are configured with Kustomize using Base and Overlay folder to patch the yaml for muliple enviornments during deployment.
<img width="2587" height="695" alt="image" src="https://github.com/user-attachments/assets/70a53d24-fee3-44ea-94d0-ee58c046466d" />


**Key Kubernetes Resources:**
- Deployments with resource requests/limits  
- Pod Security Context (non-root user, runAsUser, runAsGroup)  
- Configuration and Secrets needs to fetch from Azure App configuration and Key vault respectively using SDK for enhanced security (Declared as Env) 
- Liveness and readiness probes  
- HPA 
- Service Account using Workload identity using Azure federated credentials if required
- Role and Rolebindings if required for the service account
- Sevice and Ingress Object

### CI/CD Pipeline Overview

1. Workflow uses Azure identity with federated credentias for the authentication by Github Actions and Terraform
2. Repository wise variables and secrets are used inside the workflow
3. Environments are created (Dev & Prod) to use within deployment job to pick the environment. Also environment wise variables and secrets are used inside the workflow
4. Gated pipelines use Pull request as trigger
5. CICD pipelines uses Push trigger on main branch
6. permissions: id-token: write is used. This permission allows the GitHub Actions workflow to request an OpenID Connect (OIDC) token from GitHub’s identity provider. That token is then used to authenticate to azure without using long-lived secrets.

---

##  Monitoring & Reporting

### Prometheus + Grafana Setup
1. Installed using Helm charts
2. Custom release names for better traceability
3. Grafana admin credentials stored in Key Vault
4. Configured pod based annotation for scraping app metrics

Prometheus Dashboard

<img width="2218" height="850" alt="image" src="https://github.com/user-attachments/assets/935b5a72-907f-4a92-82b5-f1b6d87fc1a0" />

Grafana Dashboard

<img width="2216" height="1287" alt="image" src="https://github.com/user-attachments/assets/79513a83-6b2c-4454-b492-e11de10056d1" />

Workflow status

Application Deployment Status

<img width="1845" height="958" alt="image" src="https://github.com/user-attachments/assets/02251223-9578-4f93-8edf-2329aa6f8ef1" />

Monitoring Deployment status

<img width="2351" height="855" alt="image" src="https://github.com/user-attachments/assets/8802c7ce-9a7d-49fe-bc96-c7af44549d33" />

Terraform deployment status

<img width="1854" height="857" alt="image" src="https://github.com/user-attachments/assets/80a933f8-9204-4f21-94ac-9d45c66752ce" />
