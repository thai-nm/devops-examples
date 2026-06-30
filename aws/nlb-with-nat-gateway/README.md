# NLB with NAT Gateway — Simple AWS VPC Architecture

A single-AZ demo that puts an internet-facing Network Load Balancer in a public subnet and two EC2 instances in a private subnet. Outbound internet traffic from the instances flows through a NAT Gateway.

```
Internet
    │
Internet Gateway
    │
Public Subnet (AZ-a)
  ├── NLB  ──────────────────────────┐   (inbound path)
  └── NAT Gateway (EIP)             │
         ▲                          ▼
         │ (outbound path)   Private Subnet (AZ-a)
         └──────────────────── VM1 / VM2
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.0
- An AWS account with permissions to create VPCs, EC2, and ELB resources

---

## Authenticate with AWS

The easiest ways to give Terraform access to your AWS account:

### Option 1 — Environment variables (quickest for a demo)

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="ap-southeast-1"
```

You can generate these keys in the AWS Console under **IAM → Users → your user → Security credentials → Create access key**.

### Option 2 — AWS CLI profile

1. Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
2. Run:
   ```bash
   aws configure
   ```
   Enter your Access Key ID, Secret Access Key, default region, and output format when prompted.
3. Terraform automatically picks up the `default` profile. To use a named profile:
   ```bash
   export AWS_PROFILE="my-profile"
   ```

---

## Run

```bash
cd aws/nlb-with-nat-gateway/terraform

# Download provider plugins
terraform init

# Preview what will be created
terraform plan

# Create resources (~3–5 min, NAT Gateway takes the longest)
terraform apply
```

Type `yes` when prompted to confirm.

After apply completes you will see:

```
nlb_dns_name          = "nlb-nat-nlb-xxxx.elb.ap-southeast-1.amazonaws.com"
nat_gateway_public_ip = "x.x.x.x"
vm1_private_ip        = "10.0.2.x"
vm2_private_ip        = "10.0.2.y"
```

---

## Customise

Override any variable without editing files:

```bash
terraform apply \
  -var="aws_region=us-east-1" \
  -var="availability_zone=us-east-1a" \
  -var="ami_id=ami-xxxxxxxxxxxxxxxxx" \
  -var="key_pair_name=my-key"
```

> **AMI note:** The default AMI (`ami-0672fd5b9210b2bf4`) is Amazon Linux 2023 in `ap-southeast-1`. If you change the region you must also provide a matching AMI ID.

---

## Clean up

```bash
terraform destroy
```

This removes **all** resources created by this configuration.
