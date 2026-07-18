# TerraWeek Day 05 — Terraform Modules and Count

## Overview

This project demonstrates how to create and consume a reusable Terraform child module.

The root Terraform configuration discovers an Amazon Linux AMI, reads user-defined values from `terraform.tfvars`, and passes the required values into a reusable EC2 child module.

The EC2 module uses Terraform's `count` meta-argument to create multiple EC2 instances from one resource block.

This project also uses an encrypted, versioned Amazon S3 bucket as a remote Terraform backend with native S3 state locking.

---

## Learning objectives

This lab covers:

- Terraform root modules
- Terraform child modules
- Module inputs
- Module outputs
- Root and child variable scope
- Explicit value passing between modules
- The `count` meta-argument
- `count.index`
- Splat expressions
- AWS AMI data sources
- Remote state in Amazon S3
- Native S3 state locking
- S3 versioning and encryption
- Provider default tags
- Safe infrastructure cleanup

---

## Architecture

```text
terraform.tfvars
        |
        v
Root variables.tf
        |
        +------------------------------+
        |                              |
        v                              v
Root data.tf                     Root main.tf
Finds latest AL2023 AMI          Calls EC2 child module
                                       |
                                       | Module inputs
                                       v
                             modules/ec2/variables.tf
                                       |
                                       v
                               modules/ec2/main.tf
                              Creates 3 EC2 instances
                               using count and count.index
                                       |
                                       v
                            modules/ec2/outputs.tf
                                       |
                                       | Module outputs
                                       v
                              Root outputs.tf
                                       |
                                       v
                         Terraform terminal output
```

---

## Project structure

```text
day05/
├── backend_infra/
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── locals.tf
│   ├── main.tf
│   └── outputs.tf
│
├── modules/
│   └── ec2/
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
│
├── screenshots/
├── backend.tf
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── variables.tf
├── versions.tf
├── tasks.md
└── README.md
```

---

# Root module and child module

## Root module

The root module is the directory where Terraform commands are executed.

In this project, the root module is:

```text
day05/
```

The root module is responsible for:

- configuring the AWS provider,
- configuring the S3 backend,
- reading values from `terraform.tfvars`,
- finding the Amazon Linux AMI,
- calling the EC2 child module,
- passing values into the child module,
- and displaying values returned by the child module.

## Child module

The child module is located at:

```text
modules/ec2/
```

It is responsible for:

- accepting EC2 configuration through input variables,
- creating EC2 instances,
- applying secure instance settings,
- generating instance names,
- and exposing instance information through outputs.

The child module does not automatically read the root module's variables or `terraform.tfvars`.

The root must explicitly pass every required value through the module block.

---

# How root and child modules communicate

Root and child modules have separate variable scopes.

A root variable and a child variable can have the same name, but that does not connect them automatically.

The connection is created inside the root module's `module` block.

Example:

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = var.instance_type
}
```

The left side:

```hcl
instance_type =
```

refers to the child module input declared in:

```text
modules/ec2/variables.tf
```

The right side:

```hcl
var.instance_type
```

refers to the root module variable declared in:

```text
day05/variables.tf
```

The names do not need to match.

For example, this would also work:

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = var.ec2_size
}
```

The module block explicitly connects the two values.

---

# Input flow

## Instance type

The value begins in:

```hcl
instance_type = "t3.micro"
```

inside `terraform.tfvars`.

Terraform follows this path:

```text
terraform.tfvars
        |
        v
Root var.instance_type
        |
        v
module "ec2"
instance_type = var.instance_type
        |
        v
Child var.instance_type
        |
        v
aws_instance.this
instance_type = var.instance_type
```

## Instance count

The root receives:

```hcl
instance_count = 3
```

and passes it to the child:

```hcl
module "ec2" {
  instance_count = var.instance_count
}
```

The child uses it here:

```hcl
count = var.instance_count
```

Terraform creates:

```text
module.ec2.aws_instance.this[0]
module.ec2.aws_instance.this[1]
module.ec2.aws_instance.this[2]
```

## AMI ID

The root module finds the latest Amazon Linux 2023 AMI through a data source:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
}
```

The discovered AMI ID is passed into the child module:

```hcl
ami_id = data.aws_ami.amazon_linux.id
```

The child receives it as:

```hcl
var.ami_id
```

and uses it in the EC2 resource:

```hcl
ami = var.ami_id
```

---

# EC2 child module

## Child variables

The child module declares its expected inputs in:

```text
modules/ec2/variables.tf
```

Inputs include:

- `ami_id`
- `instance_type`
- `instance_count`
- `instance_name`

The module does not decide these values itself. The root module provides them.

## EC2 resource

The child module creates EC2 instances with:

```hcl
resource "aws_instance" "this" {
  count = var.instance_count

  ami           = var.ami_id
  instance_type = var.instance_type
}
```

The resource name `this` is a common module convention. It indicates that this is the primary resource managed by the module.

---

# Understanding count

The following line controls how many EC2 instances Terraform creates:

```hcl
count = var.instance_count
```

When:

```hcl
instance_count = 3
```

Terraform creates three resource instances.

Terraform identifies them by zero-based index:

```text
aws_instance.this[0]
aws_instance.this[1]
aws_instance.this[2]
```

## count.index

The EC2 `Name` tag uses:

```hcl
Name = "${var.instance_name}-${count.index + 1}"
```

Terraform's indexes begin at zero:

```text
0
1
2
```

Adding one creates human-friendly names:

```text
terraweek-day05-modules-lab-ec2-1
terraweek-day05-modules-lab-ec2-2
terraweek-day05-modules-lab-ec2-3
```

---

# Why all instances use the same instance type

This configuration uses:

```hcl
instance_type = var.instance_type
```

One instance type is passed into the module, so all resources created with `count` use the same value.

Example:

```text
Instance 1 → t3.micro
Instance 2 → t3.micro
Instance 3 → t3.micro
```

This is useful for identical resources.

For individually configured instances, `for_each` with a map is generally a better design. That topic will be covered in Day 6.

---

# Child outputs

Resources inside a child module are not referenced directly from the root module.

The child module must expose selected values through outputs.

Example:

```hcl
output "instance_ids" {
  value = aws_instance.this[*].id
}
```

The splat expression:

```hcl
aws_instance.this[*].id
```

means:

> Return the ID attribute from every EC2 instance created by this resource.

The child module exposes:

- instance IDs,
- private IP addresses,
- instance Name tags.

---

# Why instance_name is not an EC2 attribute

The module receives:

```hcl
var.instance_name
```

but the AWS EC2 resource does not have a Terraform attribute named:

```hcl
instance_name
```

The visible EC2 name is stored in the `Name` tag.

Therefore, the output uses:

```hcl
aws_instance.this[*].tags["Name"]
```

instead of:

```hcl
aws_instance.this[*].instance_name
```

---

# Root outputs

The root reads the child outputs using:

```hcl
module.ec2.instance_ids
```

The reference contains:

```text
module        ec2             instance_ids
  |            |                   |
keyword    module name        child output name
```

The root can expose the child values again:

```hcl
output "ec2_instance_ids" {
  value = module.ec2.instance_ids
}
```

The complete output flow is:

```text
aws_instance.this[*].id
        |
        v
Child output "instance_ids"
        |
        v
module.ec2.instance_ids
        |
        v
Root output "ec2_instance_ids"
        |
        v
terraform output
```

---

# Why the child module contains only three files

The child module contains:

```text
variables.tf
main.tf
outputs.tf
```

These names are conventions, not Terraform requirements.

Terraform loads every `.tf` file in the directory as one configuration.

The three-file structure clearly separates:

```text
variables.tf → values entering the module
main.tf      → resources created by the module
outputs.tf   → values leaving the module
```

## Why there is no backend.tf

Only the root module configures the backend.

The child module's resources are stored in the root module's state file.

## Why there is no terraform.tfvars

`terraform.tfvars` supplies values to the root module.

The root selectively passes values into the child through the module block.

## Why there is no provider.tf

The root configures the AWS provider.

The child normally inherits the provider configuration from the root.

Keeping provider configuration outside the child improves module reusability.

## Could a child module contain more files?

Yes.

A larger child module may include:

```text
data.tf
locals.tf
versions.tf
security-groups.tf
iam.tf
networking.tf
```

The three files used here are enough for this focused EC2 module.

---

# Remote backend

The root module stores state in Amazon S3:

```hcl
terraform {
  backend "s3" {
    bucket       = "saftab4-terraweek-day05-state"
    key          = "modules-demo/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

The bucket is created separately in:

```text
backend_infra/
```

The backend bucket includes:

- versioning,
- server-side encryption,
- public-access blocking,
- and `force_destroy` for lab cleanup.

`use_lockfile = true` enables native S3 state locking.

---

# Security settings

Each EC2 instance uses IMDSv2:

```hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
```

Each root EBS volume uses:

```hcl
root_block_device {
  encrypted   = true
  volume_type = "gp3"
  volume_size = 8
}
```

These settings provide:

- token-based instance metadata access,
- encrypted root storage,
- and modern GP3 volumes.

---

# Terraform commands

## Backend infrastructure

```bash
cd backend_infra
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Root module

```bash
cd ..
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## View outputs

```bash
terraform output
```

## View state resources

```bash
terraform state list
```

## Destroy root infrastructure

```bash
terraform plan -destroy
terraform destroy
```

## Destroy backend after root resources

```bash
cd backend_infra
terraform destroy
```

The application infrastructure must be destroyed before deleting the remote backend bucket.

---

# Cleanup order

Correct cleanup order:

```text
1. Destroy EC2 infrastructure
2. Confirm the root state contains no resources
3. Destroy the S3 backend bucket
```

Incorrect cleanup order:

```text
1. Delete the backend bucket
2. Attempt to destroy EC2
```

Deleting the backend first removes Terraform's access to the state used to manage the EC2 resources.

---

# Key lessons

- A Terraform module is a reusable package of infrastructure code.
- The root module coordinates the overall deployment.
- Child modules have separate variable scopes.
- Matching variable names do not automatically connect modules.
- Values are passed explicitly through module arguments.
- Child outputs expose selected resource information.
- Root outputs can display or forward child outputs.
- `count` creates multiple similar resources.
- `count.index` provides a numerical index for each resource.
- Splat expressions collect an attribute from all counted resources.
- Backends belong in the root module, not child modules.
- The remote backend should be destroyed only after managed infrastructure.

---

# Day 6 preview

Day 6 will expand these concepts by introducing:

- `for_each`
- maps
- lists
- sets
- provider aliases
- a reusable VPC module
- a custom security group
- EC2 instances inside the custom VPC
- module-to-module communication

The VPC module will output networking information, and the root module will pass those values into the EC2 module.

```text
VPC module output
        |
        v
Root module
        |
        v
EC2 module input
```

This will demonstrate how reusable child modules are connected to build larger infrastructure.
