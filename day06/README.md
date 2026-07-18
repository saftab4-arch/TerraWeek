# TerraWeek Day 06 – Terraform Providers

## Overview

Day 6 focused on one of the core concepts of Terraform: **Providers**. A provider is a plugin that enables Terraform to communicate with external APIs and cloud platforms. Without a provider, Terraform cannot provision or manage infrastructure.

For this lab, I configured the official **HashiCorp AWS Provider** and deployed a small networking environment inside AWS to understand how Terraform authenticates, downloads provider plugins, creates infrastructure, tracks state, detects configuration changes, and destroys managed resources.

---

# Objectives

- Understand what Terraform Providers are
- Configure the AWS Provider
- Authenticate Terraform using AWS CLI credentials
- Deploy AWS infrastructure using Terraform
- Modify existing infrastructure
- Destroy Terraform-managed resources
- Observe Terraform's execution workflow

---

# Technologies Used

- Terraform v1.6+
- AWS Provider (HashiCorp)
- AWS CLI
- Amazon VPC
- Amazon Subnet
- Internet Gateway
- Route Table
- Route Table Association

---

# Project Structure

```
day06/
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
└── README.md
```

---

# What is a Terraform Provider?

Terraform itself does not know how to communicate with AWS, Azure, Google Cloud, Kubernetes, GitHub, or any other platform.

Instead, Terraform uses **Providers**, which are plugins responsible for interacting with a platform's API.

Examples include:

| Provider | Purpose |
|-----------|---------|
| AWS | Manage AWS infrastructure |
| Azure | Manage Microsoft Azure resources |
| Google | Manage Google Cloud resources |
| Kubernetes | Deploy Kubernetes objects |
| Helm | Install Helm charts |
| GitHub | Manage GitHub repositories |

For this lab I used the official AWS Provider maintained by HashiCorp.

---

# AWS Provider Configuration

The provider was configured to deploy resources into the **us-east-1** AWS Region while automatically applying default tags to all resources.

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
```

---

# Authentication

Terraform authenticated using credentials already configured through the AWS CLI.

Authentication was verified before deployment using:

```bash
aws sts get-caller-identity
```

Using AWS CLI credentials eliminates the need to hardcode AWS access keys inside Terraform configuration files.

---

# Infrastructure Deployed

This lab deployed a small AWS networking environment consisting of:

```
AWS Provider
      │
      ▼
Custom VPC
      │
      ▼
Public Subnet
      │
      ▼
Internet Gateway
      │
      ▼
Public Route Table
      │
      ▼
Route Table Association
```

Terraform automatically determined the correct order of resource creation by analyzing dependencies between resources.

---

# Terraform Workflow

## 1. Initialize Terraform

```bash
terraform init
```

Purpose:

- Downloads the AWS Provider plugin
- Initializes the working directory
- Creates the `.terraform` directory
- Generates `.terraform.lock.hcl`

---

## 2. Validate Configuration

```bash
terraform validate
```

Purpose:

- Checks Terraform syntax
- Verifies configuration correctness
- Detects configuration errors before deployment

---

## 3. Review Execution Plan

```bash
terraform plan
```

Purpose:

- Compares configuration with current infrastructure
- Displays planned actions
- Prevents unexpected changes

---

## 4. Deploy Infrastructure

```bash
terraform apply
```

Purpose:

- Creates AWS resources
- Updates Terraform State
- Displays generated outputs

---

## 5. Inspect Terraform State

```bash
terraform state list
```

Purpose:

Displays all resources currently managed by Terraform.

Example:

```
aws_vpc.main
aws_subnet.public
aws_internet_gateway.main
aws_route_table.public
aws_route_table_association.public
```

---

## 6. Modify Infrastructure

After deployment, I updated the project name within `terraform.tfvars`.

Running:

```bash
terraform plan
```

showed that Terraform detected only the required changes instead of recreating the infrastructure.

This demonstrates Terraform's ability to compare the desired configuration with the current infrastructure and perform only the necessary updates.

---

## 7. Destroy Infrastructure

```bash
terraform destroy
```

Purpose:

Safely removes every resource managed by Terraform while maintaining consistency with the Terraform state file.

---

# Files Used

| File | Purpose |
|------|---------|
| versions.tf | Terraform and Provider version requirements |
| provider.tf | AWS Provider configuration |
| variables.tf | Input variable definitions |
| terraform.tfvars | Environment-specific values |
| main.tf | AWS resource definitions |
| outputs.tf | Output resource IDs |
| README.md | Project documentation |

---

# Key Concepts Learned

### Terraform Providers

Terraform communicates with cloud platforms through Providers.

---

### AWS Authentication

Terraform can securely authenticate using AWS CLI credentials instead of embedding access keys inside configuration files.

---

### Dependency Graph

Terraform automatically builds a dependency graph between resources.

For example:

```
VPC
 │
 ├── Subnet
 │
 ├── Internet Gateway
 │
 └── Route Table
          │
          ▼
Route Table Association
```

This ensures resources are created in the correct order without manually specifying execution order.

---

### Terraform State

Terraform records all managed infrastructure inside the Terraform State file.

The state file enables Terraform to:

- Track existing resources
- Detect configuration drift
- Determine required changes
- Destroy managed infrastructure safely

---

# Screenshots

- Project Directory
- AWS Authentication (`aws sts get-caller-identity`)
- Terraform Init
- Terraform Validate
- Terraform Plan
- Terraform Apply
- Terraform State List
- AWS Console (VPC)
- AWS Console (Subnet)
- AWS Console (Internet Gateway)
- AWS Console (Route Table)
- Terraform Plan After Modification
- Terraform Destroy

---

# Skills Practiced

- Infrastructure as Code (IaC)
- Terraform Providers
- AWS Authentication
- Amazon VPC Networking
- Terraform State Management
- Terraform Planning
- Infrastructure Deployment
- Infrastructure Modification
- Infrastructure Destruction
- AWS Resource Tagging

---

# Lessons Learned

This lab demonstrated how Terraform uses Providers to interact with cloud platforms and automate infrastructure provisioning.

I gained hands-on experience configuring the AWS Provider, authenticating with AWS, deploying networking resources, inspecting Terraform State, modifying infrastructure, and safely destroying cloud resources.

These concepts form the foundation for more advanced Terraform workflows involving reusable modules, remote state backends, CI/CD pipelines, security scanning, and production-scale infrastructure deployments.
