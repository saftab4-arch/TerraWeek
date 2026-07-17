# Day 04 – Terraform Remote Backend with Amazon S3

## Overview

This project demonstrates how to store Terraform state remotely in Amazon S3 instead of keeping `terraform.tfstate` only on a local machine.

The lab is divided into two Terraform root configurations:

1. `backend_infra` – Creates the S3 bucket used for remote Terraform state.
2. `backend_demo` – Creates an EC2 instance while storing its Terraform state inside the S3 backend.

The project also demonstrates:

- S3 bucket versioning
- Server-side encryption
- S3 public access blocking
- Native S3 state locking
- Terraform variables and `terraform.tfvars`
- Provider default tags
- Terraform locals
- AWS AMI data sources
- EC2 provisioning
- EBS root volume configuration
- Terraform outputs
- Remote-state testing
- Infrastructure cleanup

---

## Architecture

```text
Local Workstation
      |
      | terraform init
      | terraform plan
      | terraform apply
      v
Terraform CLI
      |
      | Reads and updates remote state
      v
Amazon S3 Backend
saftab4-terraweek-day04-state
      |
      └── backend-demo/
            └── terraform.tfstate
                      |
                      | Tracks
                      v
                Amazon EC2
                      |
                      └── Root EBS Volume
Project Structure
day04/
├── .gitignore
├── README.md
├── tasks.md
│
├── backend_infra/
│   ├── .terraform.lock.hcl
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── locals.tf
│   ├── main.tf
│   └── outputs.tf
│
└── backend_demo/
    ├── .terraform.lock.hcl
    ├── versions.tf
    ├── backend.tf
    ├── provider.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── locals.tf
    ├── data.tf
    ├── main.tf
    └── outputs.tf
Part 1 – Backend Infrastructure

The backend_infra project creates the S3 bucket that stores Terraform state for other Terraform projects.

Resources Created
Amazon S3 bucket
S3 bucket versioning
Server-side encryption
Public access block
Why Use an S3 Backend?

A local state file only exists on one machine.

This creates several problems:

The state can be accidentally deleted.
Team members cannot safely share the same state.
Concurrent Terraform operations can create conflicts.
Sensitive infrastructure details may remain on a local workstation.
Recovery is harder if the machine is lost.

An S3 backend provides:

Centralized remote state
State version history
Encryption
Better collaboration
State recovery
State locking
versions.tf
terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

This file defines:

The minimum Terraform version
The required AWS provider
The supported provider version range
provider.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

The AWS provider uses a variable for the region.

The default_tags block automatically applies common tags to supported AWS resources.

variables.tf
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name used for resource tagging"
  type        = string
}

Variables keep environment-specific values separate from the resource definitions.

terraform.tfvars
aws_region       = "us-east-1"
state_bucket_name = "saftab4-terraweek-day04-state"
project_name     = "terraweek-day04-backend"
environment      = "lab"

The S3 bucket name must be globally unique.

locals.tf
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

The local value creates one reusable map of tags.

main.tf
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
S3 Versioning

Versioning keeps previous copies of the Terraform state file.

If a state file is accidentally overwritten or corrupted, an earlier version may be recovered.

Encryption

The bucket uses server-side encryption with AES-256.

sse_algorithm = "AES256"
Public Access Block

Terraform state may contain sensitive infrastructure information.

The public access block prevents the bucket from being exposed publicly.

outputs.tf
output "state_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}
Deploying the Backend Infrastructure

Enter the backend project:

cd backend_infra

Format the Terraform files:

terraform fmt

Initialize Terraform:

terraform init

Validate the configuration:

terraform validate

Review the execution plan:

terraform plan

Create the resources:

terraform apply

Confirm with:

yes
Part 2 – Remote Backend Demo

The backend_demo project creates an EC2 instance and stores its state remotely in the S3 bucket created by backend_infra.

Backend Configuration
backend.tf
terraform {
  backend "s3" {
    bucket       = "saftab4-terraweek-day04-state"
    key          = "backend-demo/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

The remote state is stored at:

s3://saftab4-terraweek-day04-state/backend-demo/terraform.tfstate

The key is the object path inside the S3 bucket.

A professional naming pattern for future projects is:

environment/component/terraform.tfstate

Examples:

key = "dev/ec2/terraform.tfstate"
key = "dev/network/terraform.tfstate"
key = "prod/eks/terraform.tfstate"

Each independent Terraform root configuration must use a unique backend key.

Why Backend Variables Do Not Work

Terraform backend blocks do not support normal variable references.

This does not work:

region = var.aws_region

Backend initialization happens before Terraform evaluates:

Input variables
terraform.tfvars
Locals
Data sources
Resources

The backend needs concrete values so Terraform knows where to find the state before evaluating the remaining configuration.

Therefore, literal values inside a backend block are normal.

data.tf
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

This data source asks AWS for the most recent official Amazon Linux 2023 AMI.

It avoids hardcoding an AMI ID.

A hardcoded AMI may:

Become outdated
Differ between AWS regions
Require manual maintenance

The selected AMI is referenced with:

data.aws_ami.amazon_linux.id
main.tf
resource "aws_instance" "backend_demo" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2"
  }
}
EC2 Metadata Options
http_tokens = "required"

This requires Instance Metadata Service Version 2.

IMDSv2 uses session tokens and is more secure than allowing IMDSv1.

The EC2 metadata service is available from inside an instance through:

169.254.169.254

It can provide information such as:

Instance ID
Availability Zone
Region
IAM role credentials
Root Block Device

AWS automatically creates a root EBS volume when an EC2 instance launches.

The root_block_device block explicitly defines the required storage settings:

encrypted   = true
volume_type = "gp3"
volume_size = 8

This prevents the configuration from relying only on AMI or account defaults.

outputs.tf
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.backend_demo.id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.backend_demo.private_ip
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI selected by the data source"
  value       = data.aws_ami.amazon_linux.id
}

output "remote_state_location" {
  description = "S3 location of the Terraform state file"
  value       = "s3://saftab4-terraweek-day04-state/backend-demo/terraform.tfstate"
}
Initializing the Remote Backend

Enter the demo directory:

cd ../backend_demo

Format the files:

terraform fmt

Initialize the S3 backend:

terraform init

Terraform connects to the S3 bucket and configures remote state.

If the backend configuration changes, reinitialize using:

terraform init -reconfigure
Deploying the EC2 Demo

Validate the configuration:

terraform validate

Review the plan:

terraform plan

Create the EC2 instance:

terraform apply

Confirm with:

yes

Terraform then:

Reads the existing state from S3.
Queries AWS for the latest Amazon Linux 2023 AMI.
Creates the EC2 instance.
Creates and attaches the root EBS volume.
Updates the Terraform state.
Uploads the updated state to S3.
Remote State Verification
Verify the Managed Resource
terraform state list

Expected result:

aws_instance.backend_demo

This works even without a local terraform.tfstate file because Terraform reads the remote state from S3.

Inspect the State
terraform state show aws_instance.backend_demo

This displays the attributes Terraform tracks for the EC2 instance.

Pull the Remote State
terraform state pull

This prints the remote state as JSON.

The output comes from:

s3://saftab4-terraweek-day04-state/backend-demo/terraform.tfstate
Testing State Updates and S3 Versioning

The EC2 instance was initially created as:

instance_type = "t3.micro"

The value was changed to:

instance_type = "t3.small"

Then the following command was executed:

terraform plan

Terraform detected:

t3.micro -> t3.small

Terraform knew the existing EC2 instance type because it read the remote state stored in S3.

After running:

terraform apply

Terraform updated the existing EC2 instance in place.

S3 then displayed multiple versions of:

backend-demo/terraform.tfstate

This proved that:

Terraform was using the remote backend
State changes were uploaded to S3
S3 versioning preserved older state versions
Terraform compared the configuration against the remote state
Local Files After Remote Backend Initialization

With remote state configured, the main state file is not stored in the project directory.

The local folder still contains:

.terraform/
.terraform.lock.hcl

The hidden .terraform directory contains local initialization and backend metadata.

The authoritative infrastructure state remains in S3.

To view hidden files:

ls -la
State Locking

The backend uses:

use_lockfile = true

Terraform creates a lock file in S3 while a state-changing operation is running.

The purpose of state locking is to prevent two users or automation systems from modifying the same Terraform state at the same time.

Without state locking, concurrent operations could corrupt the state or create conflicting infrastructure changes.

Modern Terraform can use native S3 locking, removing the need for a separate DynamoDB locking table for this configuration.

Destruction Order

The EC2 infrastructure must be destroyed before deleting the backend bucket.

Correct order:

1. Destroy backend_demo resources
2. Verify EC2 and EBS are deleted
3. Destroy backend_infra resources
4. Verify the S3 bucket is deleted
Destroy the EC2 Demo

From backend_demo:

terraform destroy

Confirm with:

yes

This destroys:

EC2 instance
Root EBS volume

Terraform then updates the S3 state to show that no managed EC2 resources remain.

Destroy the Backend Bucket

A versioned S3 bucket may contain:

Current object versions
Previous object versions
Delete markers

Terraform cannot normally delete a non-empty bucket.

For lab cleanup, the S3 bucket resource can temporarily use:

force_destroy = true

Example:

resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.state_bucket_name
  force_destroy = true
}

Apply the configuration change first:

terraform apply

Then destroy the backend infrastructure:

terraform destroy

force_destroy = true allows Terraform to delete all object versions and remove the bucket.

This option must be used carefully in production because it permits permanent deletion of every object and state version in the bucket.

.gitignore

The following .gitignore prevents generated Terraform files and local state from being committed:

# Terraform working directories
**/.terraform/*

# Terraform state files
*.tfstate
*.tfstate.*

# Terraform plan files
*.tfplan

# Crash logs
crash.log
crash.*.log

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Terraform CLI configuration
.terraformrc
terraform.rc

# Visual Studio Code
.vscode/

# macOS
.DS_Store

The .terraform.lock.hcl files are intentionally committed.

They record the selected provider versions and help ensure consistent provider installation across machines.

The terraform.tfvars files were committed in this lab because they contain only non-sensitive values.

Production repositories commonly ignore the real variable file and commit an example instead:

terraform.tfvars.example

Secrets such as passwords, API keys, and cloud credentials should never be committed.

Git Workflow

The day04 folder is part of the existing TerraWeek repository.

A nested Git repository should not be created inside day04.

Git commands should be run from the root TerraWeek repository:

cd TerraWeek

Check the repository:

git status

Stage Day 4:

git add day04

Commit:

git commit -m "Day 04: Terraform Remote Backend with S3 State Management"

Push:

git push origin main
Important Lessons Learned
Local State vs Remote State
Local state
Developer computer
└── terraform.tfstate

Problems:

Single-machine dependency
Difficult collaboration
Easy accidental loss
No centralized locking
Limited recovery
Remote state
Developer computer
        |
        v
Amazon S3
└── environment/component/terraform.tfstate

Benefits:

Centralized state
Version recovery
Encryption
State locking
Team access
Better automation support
Backend Configuration vs Provider Configuration

The backend controls where Terraform stores its state.

terraform {
  backend "s3" {
    region = "us-east-1"
  }
}

The provider controls where Terraform creates AWS resources.

provider "aws" {
  region = var.aws_region
}

The backend cannot use normal variables, while the provider can.

Data Source vs Resource

A resource creates or manages infrastructure:

resource "aws_instance" "backend_demo" {
}

A data source reads information that already exists:

data "aws_ami" "amazon_linux" {
}

In this project:

The AMI already existed and was read through a data source.
The EC2 instance did not exist and was created through a resource.
Terraform Dependency Flow
terraform.tfvars
        |
        v
variables.tf
        |
        v
locals.tf
        |
        v
provider.tf
        |
        v
data.tf
        |
        v
main.tf
        |
        v
outputs.tf

The backend is initialized separately before normal configuration evaluation.

Troubleshooting
Error: Invalid AWS Region

Example:

Error: Invalid region value
Invalid AWS Region: var.aws_region

Cause:

region = "var.aws_region"

Terraform interpreted var.aws_region as literal text.

Backend blocks also do not support:

region = var.aws_region

Fix:

region = "us-east-1"

Then run:

terraform init -reconfigure
Error: Origin Does Not Appear to Be a Git Repository

Example:

fatal: 'origin' does not appear to be a git repository

Cause:

A new Git repository was initialized inside day04, so it was not connected to the existing TerraWeek remote repository.

Fix:

Remove the nested repository:

rm -rf day04/.git

Then run Git commands from the TerraWeek root.

Error: Bucket Not Empty

Example:

BucketNotEmpty

Cause:

S3 versioning retained previous Terraform state versions.

Fix for lab cleanup:

force_destroy = true

Apply the change before destroying the bucket:

terraform apply
terraform destroy
Screenshots

Suggested screenshots for this project:

S3 backend bucket created
S3 bucket versioning enabled
S3 encryption enabled
Public access block enabled
EC2 instance created
Root EBS volume created
Terraform apply output
Remote state object stored in S3
Multiple S3 state versions
EC2 instance type updated from t3.micro to t3.small
Terraform destroy completed
AWS resources removed

Store screenshots in:

day04/screenshots/

Example:

screenshots/
├── 01-s3-backend-bucket.png
├── 02-remote-state-object.png
├── 03-ec2-created.png
├── 04-ebs-volume.png
├── 05-instance-update.png
├── 06-state-versions.png
└── 07-destroy-complete.png

You can include them in this README using:

![Remote Terraform state stored in S3](screenshots/02-remote-state-object.png)
Final Result

This project successfully demonstrated a complete Terraform remote-state workflow:

Terraform configuration
        |
        v
S3 remote backend initialized
        |
        v
EC2 infrastructure deployed
        |
        v
Terraform state uploaded to S3
        |
        v
Configuration changed
        |
        v
Remote state compared
        |
        v
EC2 updated in place
        |
        v
New S3 state version created
        |
        v
Infrastructure safely destroyed
