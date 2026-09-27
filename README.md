# AWS Auto-Healing NGINX Web Tier

Terraform infrastructure deploying two private NGINX instances across
two AWS Availability Zones, behind an Application Load Balancer.
An Auto Scaling Group automatically replaces failed instances.

## Why AWS

AWS was selected on cost grounds: its estimated monthly cost was lower than
that of the Azure configuration evaluated for this exercise. The configurations
are not identical, so this comparison does not imply that AWS is always cheaper
than Azure. The [cost report](docs/cost-estimate.md) records the sizing, regional
pricing, assumptions and differences behind the comparison.

## Verified results and limitations

Deployment and instance-replacement testing were performed in Sydney
on 25 September 2026.

- Auto Scaling automatically replaced a terminated EC2 instance.
- Both the replacement and surviving instance passed ALB health checks.
- The post-test Terraform plan reported no changes and returned exit code 0.
  See the [recorded Terraform plan result](docs/terraform-plan.md).


Verified Sydney rates give a fixed subtotal of AUD 68.33/month before
traffic and GST, assuming 730 hours and USD 1 = AUD 1.60. Illustrative
ALB usage scenarios bring this to AUD 69.27–72.07 before other transfer
charges. The AUD 20/month target is not met. See the cost report for
itemized calculations, alternatives and remaining pricing assumptions.

The deployment and tests used Sydney with `t4g.micro` instances. A costed
alternative using two `t4g.nano` instances in Mumbai reduces the fixed estimate
to **AUD 48.47/month (approximately AUD 48)**, excluding ALB usage, internet
data transfer and GST. With average ALB usage of 0.1–0.4 LCU, this becomes
AUD 49.41–52.21/month before transfer and GST. Mumbai has not been deployed or
tested; the existing Sydney configuration is unchanged.

See [cost assumptions](docs/cost-estimate.md).

See [architecture and AWS–Azure comparison](docs/architecture.md) for
the network design and recovery behaviour.

## Architecture

```text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
Public subnets across two Availability Zones
   |
   +-------------------------+
   |                         |
NGINX EC2                 NGINX EC2
Private subnet            Private subnet
Availability Zone A       Availability Zone B
   |                         |
   +---- Auto Scaling Group -+
         Desired capacity: 2

Private subnet route tables
   |
S3 gateway endpoint
   |
Regional Amazon Linux package repository
```

The ALB distributes requests to healthy instances. Auto Scaling uses
ELB health checks to identify unhealthy instances and replace them.

Instances have no public IP addresses. Their security group accepts
HTTP traffic only from the ALB security group. An S3 gateway endpoint
provides access to the Amazon Linux package repository without a
NAT Gateway.

NGINX is installed during startup. The page displays the instance
hostname, and `/health` provides the health-check endpoint.

## Repository layout

- `modules/network`: VPC, subnets, routes, Internet Gateway and S3 endpoint.
- `modules/load-balancer`: ALB, listener, target group and ALB security group.
- `modules/web-tier`: launch template, Auto Scaling Group, security rules
  and NGINX bootstrap script.
- Root Terraform files: provider configuration, module wiring, inputs
  and outputs.
- `docs`: architecture and cost analysis.

## Prerequisites

- Terraform >= 1.16.2 and < 2.0.0.
- AWS CLI supporting `aws login`.
- An AWS identity permitted to create the resources in this project,
  including the Auto Scaling service-linked role when needed.
- An available Amazon Linux 2023 ARM64 AMI in the selected region.

The AWS provider constraint is `~> 6.66.0`; the dependency lock file
records the selected version. Commands below use PowerShell.

## Configure authentication

```powershell
aws login --profile autoheal
$env:AWS_PROFILE = "autoheal"
aws sts get-caller-identity --profile autoheal
```

Check the returned account and identity before deploying.
`autoheal` is a local AWS profile name.

## Configure Terraform

For a new checkout, copy the example:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Do not overwrite an existing local configuration.

Review the region, project name, environment and AMI ID in
`terraform.tfvars`. The example AMI was verified in Sydney on
25 September 2026; recheck its availability before deploying.

The root configuration explicitly selects `t4g.micro`. The original
`t4g.nano` choice was rejected by the test account's Free Tier
restrictions. Eligibility does not mean every resource is free.

Local variable files, Terraform state and saved plans are excluded
from Git. Keep the dependency lock file under version control.

## Validate and deploy

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan "-out=deployment.tfplan"
```

Review the plan, then deploy the saved changes:

```powershell
terraform apply "deployment.tfplan"
terraform output -raw website_url
```

Open the resulting URL using HTTP. This demonstration does not
configure an HTTPS listener or certificate.

Creating these resources may incur charges.

## Verify the deployment

```powershell
$targetGroupArn = terraform output -raw target_group_arn

aws elbv2 describe-target-health --target-group-arn $targetGroupArn --region ap-southeast-2 --profile autoheal --output table --no-cli-pager
```

Both instances should be healthy before failure testing.

Check that a subsequent Terraform run requires no changes:

```powershell
terraform plan -detailed-exitcode
$LASTEXITCODE
```

Exit codes: `0` means no changes, `1` means an error, and `2` means
changes are proposed.

## Security and operational scope

- EC2 instances run in private subnets without public IP addresses.
- Web traffic reaches instances through the ALB.
- Root EBS volumes are encrypted.
- Instance Metadata Service v2 is required.
- SSH and Systems Manager access are not configured.
- Terraform state is local; a shared remote backend is not configured.
- HTTP is unencrypted. Production use would require additional security
  and operational work.

## Cleanup

From the same checkout with its Terraform state and AWS credentials:

```powershell
terraform plan -destroy "-out=destroy.tfplan"
```

Review the resources selected for removal, then run:

```powershell
terraform apply "destroy.tfplan"
```

Keep the Terraform state until cleanup completes. Stopping the local
terminal or HTTP monitor does not remove AWS resources.
