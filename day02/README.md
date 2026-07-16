# TerraWeek - Day 2: Variables & Terraform.tfvars

## Overview

Day 2 introduces one of Terraform's most important concepts: **variables**.

Instead of hardcoding values directly into the Terraform configuration, values are separated from the infrastructure code. This makes the same Terraform project reusable across different environments.

---

# Objectives

- Learn Terraform Variables
- Understand `terraform.tfvars`
- Pass values into Terraform
- Remove hardcoded configuration
- Deploy reusable infrastructure
- Understand variable flow

---

# Project Structure

```text
day02/
├── README.md
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
├── .gitignore
└── .terraform.lock.hcl
```

---

# Files Explained

## versions.tf

Defines:

- Required Terraform version
- Required AWS Provider version

---

## variables.tf

Declares the variables required by the project.

Variables created:

- aws_region
- bucket_name

Variables define inputs but **do not contain values**.

---

## terraform.tfvars

Provides actual values for the variables.

Example:

```hcl
aws_region = "us-east-1"

bucket_name = "syed-terraweek-day2-2026"
```

---

## provider.tf

Uses:

```hcl
region = var.aws_region
```

instead of a hardcoded region.

---

## main.tf

Creates an Amazon S3 bucket using:

```hcl
bucket = var.bucket_name
```

instead of a fixed bucket name.

---

## outputs.tf

Displays:

- Bucket Name
- Bucket ARN
- AWS Region

---

# Variable Flow

```text
terraform.tfvars
        │
        ▼
variables.tf
        │
        ▼
provider.tf
main.tf
        │
        ▼
AWS
```

Terraform automatically substitutes:

```text
var.aws_region

↓

us-east-1
```

and

```text
var.bucket_name

↓

syed-terraweek-day2-2026
```

---

# Terraform Workflow

```text
Write Configuration
        ↓
terraform fmt
        ↓
terraform init
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform apply
        ↓
Verify in AWS
        ↓
terraform destroy
```

---

# Commands Used

```bash
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

---

# AWS Resources Created

- Amazon S3 Bucket

---

# Skills Learned

- Terraform Variables
- terraform.tfvars
- Variable References
- Input Variables
- Outputs
- Infrastructure as Code
- AWS Provider
- Amazon S3

---

# Key Takeaways

- Variables make Terraform reusable.
- `variables.tf` defines required inputs.
- `terraform.tfvars` provides actual values.
- `var.<name>` references a variable anywhere in the project.
- The same Terraform code can be reused across multiple environments by changing only the variable values.

---

# Next Step

Day 3 introduces:

- Remote State
- Backend Configuration
- Child Modules
- Root Modules
- Module Inputs
- Module Outputs
