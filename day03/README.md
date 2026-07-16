# TerraWeek — Day 3: Terraform Locals and Reusable Values

## Overview

Day 3 focuses on Terraform locals and how they help reduce duplication.

The project creates an Amazon S3 bucket and applies a reusable map of common tags using `local.common_tags`.

The goal is to understand the difference between external input variables and internal reusable local values.

---

## Objectives

- Understand Terraform locals
- Compare variables and locals
- Create reusable common tags
- Reference variables inside locals
- Use local values inside resources
- Return local values through outputs
- Continue using safe Git practices

---

## Project Structure

```text
day03/
├── README.md
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars.example
├── locals.tf
├── main.tf
├── outputs.tf
├── .gitignore
└── .terraform.lock.hcl
```

The real `terraform.tfvars` file remains local and is excluded by `.gitignore`.

---

## Architecture

```text
terraform.tfvars
        │
        ▼
variables.tf
        │
        ▼
locals.tf
        │
        ▼
main.tf
        │
        ▼
Amazon S3
        │
        ▼
outputs.tf
```

---

## Variables vs Locals

### Variables

Variables accept values from outside the Terraform configuration.

Examples:

```hcl
variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}
```

Values are supplied through `terraform.tfvars`:

```hcl
aws_region  = "us-east-1"
environment = "learning"
```

Variables are appropriate when the user or environment should control the value.

---

### Locals

Locals are reusable values created inside the Terraform configuration.

Example:

```hcl
locals {
  common_tags = {
    Project     = "TerraWeek-Day-03"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

Nobody provides `common_tags` through a variable file.

Terraform builds the map internally using fixed values and existing variables.

---

## Complete Value Flow

```text
terraform.tfvars
environment = "learning"
        │
        ▼
variables.tf
variable "environment"
        │
        ▼
locals.tf
Environment = var.environment
        │
        ▼
local.common_tags
        │
        ▼
main.tf
tags = local.common_tags
        │
        ▼
AWS S3 Bucket Tags
```

---

## Why Use Locals?

Without locals, the same tags might be repeated on every resource:

```hcl
tags = {
  Project     = "TerraWeek-Day-03"
  Environment = var.environment
  ManagedBy   = "Terraform"
}
```

If the project had 30 resources, this block might be copied 30 times.

With locals, the values are defined once:

```hcl
locals {
  common_tags = {
    Project     = "TerraWeek-Day-03"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

Every resource can then use:

```hcl
tags = local.common_tags
```

This makes the configuration:

- Easier to read
- Easier to update
- Less repetitive
- More consistent
- Easier to maintain

---

## Rule to Remember

```text
If the user should decide the value:
Use a variable.

If Terraform should calculate, group, or reuse the value:
Use a local.
```

Examples:

| Value | Best Choice |
|---|---|
| AWS region | Variable |
| EC2 instance type | Variable |
| VPC CIDR | Variable |
| Environment | Variable |
| Common tags | Local |
| Calculated resource name | Local |
| Name prefix | Local |

---

## Files Explained

### `versions.tf`

Defines the required Terraform and AWS provider versions.

### `provider.tf`

Configures the AWS provider using:

```hcl
region = var.aws_region
```

### `variables.tf`

Declares:

- `aws_region`
- `bucket_name`
- `environment`

### `terraform.tfvars`

Contains the real local values used during deployment.

This file is excluded from Git.

### `terraform.tfvars.example`

Provides a safe template for anyone cloning the repository.

Create the working file with:

```bash
cp terraform.tfvars.example terraform.tfvars
```

### `locals.tf`

Creates the reusable `common_tags` map.

### `main.tf`

Creates an Amazon S3 bucket and applies:

```hcl
tags = local.common_tags
```

### `outputs.tf`

Displays:

- Bucket name
- Bucket ARN
- Environment
- Common tags

---

## Terraform Workflow

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

## AWS Resource Created

- Amazon S3 Bucket

---

## Expected Outputs

```text
bucket_name = "your-bucket-name"

bucket_arn = "arn:aws:s3:::your-bucket-name"

environment = "learning"

common_tags = {
  "Environment" = "learning"
  "ManagedBy"   = "Terraform"
  "Project"     = "TerraWeek-Day-03"
}
```

---

## Skills Practiced

- Input variables
- `terraform.tfvars`
- Terraform locals
- Maps
- Common tags
- Resource references
- Outputs
- Infrastructure as Code
- Amazon S3
- Git ignore patterns

---

## Key Takeaways

- Variables receive values from users or environments.
- Locals create reusable values inside Terraform.
- Locals may reference input variables.
- `local.<name>` accesses a local value.
- Common tags are a practical use case for locals.
- Reusable values reduce duplicated configuration.
- Terraform outputs can expose resource, variable, and local values.

---

## Next Step

Day 4 will introduce Terraform loops and multiple-resource creation using:

- `count`
- `count.index`
- `length()`
- Lists
