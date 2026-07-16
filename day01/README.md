# TerraWeek - Day 1: Terraform Fundamentals

## Overview

Day 1 focuses on learning the Terraform workflow and deploying the first AWS resource.

The goal of this lab is not to build complex infrastructure, but to understand how Terraform communicates with AWS and how Infrastructure as Code (IaC) works.

---

# Objectives

- Install and configure Terraform
- Understand Terraform Providers
- Create the first AWS resource
- Learn the Terraform workflow
- Verify resources inside AWS
- Destroy infrastructure after testing

---

# Project Structure

```text
day01/
├── README.md
├── versions.tf
├── provider.tf
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

This ensures everyone working on the project uses compatible versions.

---

## provider.tf

Configures the AWS Provider.

Also defines default resource tags so every supported AWS resource is tagged automatically.

Example:

- Project
- Environment
- ManagedBy

---

## main.tf

Contains the infrastructure to build.

For Day 1 we create:

- Amazon S3 Bucket

---

## outputs.tf

Displays useful information after deployment.

Outputs include:

- Bucket Name
- Bucket ARN

---

# Terraform Workflow

```text
Write Configuration
        ↓
terraform init
        ↓
terraform fmt
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

Initialize Terraform

```bash
terraform init
```

Format files

```bash
terraform fmt
```

Validate configuration

```bash
terraform validate
```

Review execution plan

```bash
terraform plan
```

Create infrastructure

```bash
terraform apply
```

Destroy infrastructure

```bash
terraform destroy
```

---

# AWS Resources Created

- Amazon S3 Bucket

---

# Skills Learned

- Infrastructure as Code (IaC)
- Terraform Providers
- Terraform Resources
- Terraform Outputs
- Terraform Lifecycle
- Terraform State
- AWS S3

---

# Screenshots

Include screenshots of:

- terraform plan
- terraform apply
- AWS Console
- terraform destroy

---

# Key Takeaways

- Terraform describes infrastructure using code.
- The AWS Provider allows Terraform to communicate with AWS.
- Terraform compares the desired configuration with the current infrastructure before making changes.
- Outputs provide useful information after deployment.
- Infrastructure can be created and destroyed repeatedly using the same configuration.

---

# Next Step

Day 2 introduces:

- Variables
- terraform.tfvars
- Parameterized infrastructure
- Reusable configurations
