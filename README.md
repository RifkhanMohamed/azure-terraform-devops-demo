# Azure Terraform DevOps Demo

## Project Overview

An end-to-end DevOps demonstration for deploying a containerised .NET 10 application to Microsoft Azure using Docker, Terraform and GitHub Actions.

This project demonstrates modern DevOps practices, including Infrastructure as Code (IaC), containerisation, continuous integration, continuous deployment, cloud security, infrastructure state management and application health monitoring.

## Project Objectives

- Develop a lightweight .NET 10 Web API.
- Containerise the application using Docker.
- Automate Azure infrastructure provisioning using Terraform.
- Publish Docker images to Azure Container Registry.
- Deploy the application using Azure Container Apps.
- Implement continuous integration and continuous deployment.
- Implement secure, passwordless Azure authentication using OIDC.
- Manage Terraform state using Azure Blob Storage.
- Implement application health checks and deployment verification.

## Technology Stack

| Technology | Purpose |
|---|---|
| .NET 10 | Application development |
| C# | Programming language |
| Docker | Application containerisation |
| Terraform | Infrastructure as Code |
| Microsoft Azure | Cloud infrastructure |
| Azure Container Registry | Container image storage |
| Azure Container Apps | Managed container hosting |
| Azure Blob Storage | Remote Terraform state |
| Microsoft Entra ID | Identity management |
| GitHub | Source control |
| GitHub Actions | CI/CD automation |
| OpenID Connect | Passwordless pipeline authentication |
| Azure CLI | Cloud resource management |

## System Architecture

The solution follows a container-based cloud deployment architecture.

**Application delivery flow:**

Developer → GitHub → GitHub Actions CI → GitHub Actions CD → Azure Container Registry → Azure Container Apps

**Infrastructure management flow:**

Terraform → Azure Resource Manager → Azure Infrastructure

**State management:**

Local Terraform and GitHub Actions → Azure Blob Storage

**Authentication:**

- GitHub Actions authenticates with Azure using OIDC.
- Azure Container Apps retrieves images from ACR using Managed Identity.
- Terraform accesses remote state using Microsoft Entra ID authentication.

## Repository Structure

| Path | Description |
|---|---|
| DevOpsDemo/Program.cs | Application endpoints |
| DevOpsDemo/DevOpsDemo.csproj | .NET project configuration |
| DevOpsDemo/Dockerfile | Multi-stage Docker build |
| DevOpsDemo/.dockerignore | Docker build exclusions |
| terraform/providers.tf | Terraform provider configuration |
| terraform/main.tf | Azure resource definitions |
| terraform/variables.tf | Infrastructure input variables |
| terraform/outputs.tf | Infrastructure outputs |
| terraform/backend.tf | Remote state configuration |
| terraform/terraform.tfvars.example | Example environment configuration |
| terraform/.terraform.lock.hcl | Provider dependency lock file |
| .github/workflows/ci.yml | Continuous integration workflow |
| .github/workflows/cd.yml | Continuous deployment workflow |
| .gitignore | Source control exclusions |
| README.md | Project documentation |

## Application Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | / | Application information, version and environment |
| GET | /health | Application health status |

Example health response:

    {
      "status": "Healthy",
      "timestamp": "2026-11-26T12:26:19.021941Z"
    }

## Prerequisites

The following tools are required for local development and infrastructure provisioning:

- .NET 10 SDK and runtime
- Docker Desktop
- Terraform CLI
- Azure CLI
- Git
- Visual Studio Code
- GitHub account
- Microsoft Azure subscription

## Getting Started

### 1. Clone the Repository

    git clone https://github.com/RifkhanMohamed/azure-terraform-devops-demo.git

    cd azure-terraform-devops-demo

### 2. Run the Application Locally

    cd DevOpsDemo

    dotnet restore

    dotnet run --urls http://localhost:8080

Verify the application:

    curl http://localhost:8080

Verify the health endpoint:

    curl http://localhost:8080/health

## Docker Containerisation

The application uses a multi-stage Dockerfile to separate the build environment from the runtime environment.

The build stage uses the .NET SDK image to restore dependencies, compile and publish the application.

The runtime stage uses the ASP.NET Core runtime image to execute the published application.

### Benefits

- Smaller runtime image.
- Reduced attack surface.
- Consistent application execution.
- Improved portability.
- Non-root container execution.
- Separation of build and runtime dependencies.

### Build the Docker Image

From the DevOpsDemo directory:

    docker build --platform linux/amd64 -t devops-demo:v1 .

### Run the Docker Container

    docker run -d -p 8080:8080 \
      --name devops-demo devops-demo:v1

### Verify the Container

    docker ps

    docker logs devops-demo

    curl http://localhost:8080/health

### Stop and Remove the Container

    docker stop devops-demo

    docker rm devops-demo

## Azure Infrastructure

Terraform manages the following application infrastructure:

| Resource | Name | Purpose |
|---|---|---|
| Resource Group | rg-devops-demo-dev | Logical resource organisation |
| Container Registry | rifkhandevopsdemo2026 | Private Docker image storage |
| Managed Identity | id-devops-demo | Passwordless registry authentication |
| Role Assignment | AcrPull | Container image retrieval permission |
| Container Apps Environment | cae-devops-demo | Managed container environment |
| Container App | ca-devops-demo | Application hosting |

The remote state infrastructure is managed separately from the application infrastructure.

| Resource | Purpose |
|---|---|
| rg-devops-tfstate | Separate state resource group |
| Storage Account | Terraform state storage |
| Blob Container | Remote state persistence |

## Infrastructure as Code

Terraform provides a declarative approach to infrastructure provisioning.

The infrastructure configuration is version-controlled, reusable and designed to support repeatable deployments.

### Azure Authentication

    az login

    az account show

    export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

Ensure the selected subscription is the intended deployment subscription.

### Register Azure Resource Providers

    az provider register --namespace Microsoft.App --wait

    az provider register --namespace Microsoft.ContainerRegistry --wait

    az provider register --namespace Microsoft.ManagedIdentity --wait

    az provider register --namespace Microsoft.OperationalInsights --wait

### Configure Terraform Variables

    cd terraform

    cp terraform.tfvars.example terraform.tfvars

Example configuration:

    location      = "uksouth"
    project_name  = "devops-demo"
    environment   = "dev"
    registry_name = "youruniqueregistryname"
    deploy_app    = false
    image_tag     = "v1"

The registry name must be globally unique.

### Terraform Deployment Lifecycle

    terraform init

    terraform fmt

    terraform validate

    terraform plan -out=tfplan

    terraform apply tfplan

Terraform first provisions the supporting infrastructure. The Container App is deployed after the Docker image has been published to the registry.

For a new deployment, bootstrap the remote state storage before initialising the Azure backend. Alternatively, initialise with local state and migrate it after provisioning the state storage.

## Azure Container Registry

Azure Container Registry provides private storage and distribution of Docker images.

### Authenticate with ACR

    az acr login --name rifkhandevopsdemo2026

### Tag the Docker Image

    docker tag devops-demo:v1 \
      rifkhandevopsdemo2026.azurecr.io/devops-demo:v1

### Push the Docker Image

    docker push \
      rifkhandevopsdemo2026.azurecr.io/devops-demo:v1

### Verify Published Images

    az acr repository list \
      --name rifkhandevopsdemo2026 \
      --output table

    az acr repository show-tags \
      --name rifkhandevopsdemo2026 \
      --repository devops-demo \
      --output table

## Azure Container Apps Deployment

After publishing the Docker image, update terraform.tfvars:

    deploy_app = true

Deploy the application:

    terraform plan -out=tfplan

    terraform apply tfplan

Retrieve the application URL:

    terraform output -raw application_url

Verify the deployed application:

    APP_URL=$(terraform output -raw application_url)

    curl "$APP_URL/health"

### Container Configuration

| Property | Value |
|---|---|
| Container port | 8080 |
| CPU | 0.25 vCPU |
| Memory | 0.5 GiB |
| Minimum replicas | 0 |
| Maximum replicas | 1 |
| Revision mode | Single |
| External ingress | Enabled |
| Runtime environment | Production |

Azure Container Apps was selected because it provides managed container hosting without the operational overhead of managing a Kubernetes cluster.

## Terraform Remote State

Terraform state tracks the relationship between infrastructure configuration and deployed Azure resources.

Azure Blob Storage provides a shared backend for local development and automated deployment pipelines.

### Benefits

- Centralised infrastructure state.
- Shared access between developers and CI/CD.
- State locking using Azure Blob leases.
- State persistence across temporary GitHub runners.
- Support for versioning and recovery.
- Authentication using Microsoft Entra ID.

### State Migration

After provisioning the storage account and configuring backend.tf:

    terraform init -migrate-state

Verify the migrated state:

    terraform state list

    terraform output

    terraform plan

Terraform state files must never be committed to GitHub because they may contain sensitive infrastructure information.

## Continuous Integration

The CI workflow is defined in:

.github/workflows/ci.yml

The workflow is triggered by pushes and pull requests targeting the main branch.

### CI Pipeline Stages

1. Checkout source code.
2. Configure the .NET SDK.
3. Restore application dependencies.
4. Build the application.
5. Build the Docker image.
6. Start the Docker container.
7. Verify the application health endpoint.
8. Display diagnostic logs if validation fails.
9. Clean up the test container.
10. Check Terraform formatting.
11. Initialise Terraform without the remote backend.
12. Validate Terraform configuration.

The health verification stage uses bounded retries and request timeouts to accommodate application startup delays.

## Continuous Deployment

The CD workflow is defined in:

.github/workflows/cd.yml

The deployment workflow is designed to execute only after successful CI validation of a push to the main branch.

### CD Pipeline Stages

1. Verify successful CI execution.
2. Checkout the validated Git commit.
3. Authenticate with Azure using OIDC.
4. Authenticate with Azure Container Registry.
5. Build the Docker image.
6. Tag the image using the Git commit SHA.
7. Push the image to Azure Container Registry.
8. Initialise Terraform using remote state.
9. Generate a Terraform execution plan.
10. Apply the infrastructure changes.
11. Verify the deployed application health endpoint.

Deployment concurrency controls prevent overlapping deployment jobs.

## GitHub Actions Configuration

The following repository variables are required for automated deployment:

| Variable | Description |
|---|---|
| AZURE_CLIENT_ID | Microsoft Entra application client ID |
| AZURE_TENANT_ID | Microsoft Entra tenant ID |
| AZURE_SUBSCRIPTION_ID | Target Azure subscription ID |
| ACR_NAME | Azure Container Registry name |

No permanent Azure client secret is required when using OIDC federation.

## Security and Access Control

The project follows a passwordless authentication approach where supported.

### Security Measures

- Non-root Docker container execution.
- Multi-stage Docker builds.
- Private Azure Container Registry.
- Registry administrator credentials disabled.
- Managed Identity for image retrieval.
- Role-based access control.
- OIDC federation for GitHub Actions.
- Short-lived Azure authentication tokens.
- Restricted repository and branch federation.
- HTTPS application access.
- Terraform state excluded from source control.
- Sensitive configuration excluded from source control.

### Azure RBAC Permissions

| Identity | Role | Purpose |
|---|---|---|
| Container App Managed Identity | AcrPull | Retrieve container images |
| GitHub Service Principal | AcrPush | Publish container images |
| GitHub Service Principal | Contributor | Manage application resources |
| GitHub Service Principal | Storage Blob Data Contributor | Access remote Terraform state |

Permissions are scoped to the relevant resources rather than granting subscription-wide Owner access.

Changes to Azure role assignments require separately authorised permissions.

## Image Versioning and Rollback

Docker images are tagged using the Git commit SHA during automated deployments.

This provides:

- Traceability between source code and deployed images.
- Identification of previously deployed versions.
- Support for controlled rollback.
- Improved deployment auditing.

A rollback can be performed by redeploying a previously verified image tag through Terraform.

Automated rollback is not included in the current design.

## Health Monitoring

The application exposes a dedicated health endpoint:

    GET /health

Azure Container Apps uses liveness and readiness probes.

- Liveness probes determine whether a running container requires restarting.
- Readiness probes determine whether a container is ready to receive traffic.
- CI smoke tests verify container startup and basic HTTP availability.
- CD health checks verify application availability after deployment.

### View Azure Application Logs

    az containerapp logs show \
      --name ca-devops-demo \
      --resource-group rg-devops-demo-dev \
      --follow

## Challenges and Troubleshooting

### 1. Azure Resource Provider Registration

**Issue:** Terraform returned a 409 Conflict error with MissingSubscriptionRegistration when creating the Container Apps environment.

**Cause:** The Azure subscription was not registered to use the Microsoft.App resource provider.

**Resolution approach:** Register the required Azure resource provider, verify its registration status, inspect Terraform state and generate a fresh execution plan.

**Learning:** New Azure subscriptions may require resource provider registration before deploying particular Azure services.

### 2. Terraform Variable Configuration

**Issue:** Terraform prompted for the registry_name variable.

**Cause:** The required input variable was not being loaded from the actual terraform.tfvars file.

**Resolution:** Create and save terraform.tfvars with the appropriate environment configuration.

**Learning:** Terraform does not automatically load terraform.tfvars.example.

### 3. Container Registry Repository Not Found

**Issue:** Azure Container Registry returned a repository-not-found error.

**Cause:** The requested image repository was not available in the registry.

**Resolution approach:** Authenticate with ACR, tag the local Docker image, push the image and verify the repository and image tag.

**Learning:** Creating a container registry does not automatically publish application images.

### 4. CI Container Health Check Failure

**Issue:** The GitHub Actions pipeline successfully built the Docker image but failed during the health check with curl exit code 56.

**Suspected cause:** The health check was executed before the application was ready to receive HTTP requests.

**Resolution approach:**

- Implement bounded health-check retries.
- Configure HTTP request timeouts.
- Add container diagnostic logging.
- Add automatic container cleanup.

**Learning:** Container startup does not necessarily mean application readiness. Deployment pipelines should explicitly verify application health.

## Cost Optimisation

The demonstration environment is designed to minimise cloud infrastructure costs.

- Azure Container Registry Basic SKU.
- Small Container Apps CPU and memory allocation.
- Scale-to-zero configuration.
- Maximum replica count limited to one.
- Standard locally redundant storage for Terraform state.
- Resource tagging for cost identification.
- Azure budget alerts.

Azure resources may continue to incur charges even when the application is not actively receiving traffic.

## Infrastructure Cleanup

To remove application infrastructure:

    cd terraform

    terraform plan -destroy

    terraform destroy

Review all proposed deletions before confirming.

The remote state storage is maintained separately and should only be removed after application infrastructure cleanup has been verified.

## Implementation Status

| Component | Status |
|---|---|
| .NET application | Completed |
| Local health endpoint | Verified |
| Docker image build | Verified in CI |
| GitHub repository | Created |
| Azure authentication | Verified |
| Terraform infrastructure | Provisioning undertaken |
| Azure Container Registry | Created |
| Azure Container App deployment | Verification required |
| Continuous Integration | Final verification required |
| Remote Terraform state | Planned / verification required |
| GitHub OIDC authentication | Planned / verification required |
| Continuous Deployment | Planned / verification required |

## Future Enhancements

- Automated unit and integration tests.
- Container vulnerability scanning using Trivy.
- Terraform security scanning.
- Separate development, testing and production environments.
- GitHub environment protection and deployment approvals.
- Azure Key Vault integration.
- Azure Monitor and Application Insights.
- Automated rollback.
- Blue-green and canary deployment strategies.
- Custom domains and certificates.
- Infrastructure policy enforcement.
- Disaster recovery and backup procedures.

## Key Learning Outcomes

This project demonstrates practical experience in:

- Infrastructure as Code.
- Containerisation and image management.
- Azure cloud resource provisioning.
- CI/CD pipeline design.
- Secure cloud authentication.
- Terraform state management.
- Cloud access control.
- Application health monitoring.
- Infrastructure and pipeline troubleshooting.
- Cost-aware cloud architecture.

## Author

**Mohamed Rifkhan Abdul Rahman**

Senior Software Developer

GitHub: https://github.com/RifkhanMohamed

## References

- Microsoft Azure: https://learn.microsoft.com/azure/
- Terraform: https://developer.hashicorp.com/terraform/docs
- Docker: https://docs.docker.com/
- GitHub Actions: https://docs.github.com/actions
- .NET: https://learn.microsoft.com/dotnet/

## Disclaimer

This project is developed for educational and professional development purposes using a personal Azure subscription and personal GitHub repository.