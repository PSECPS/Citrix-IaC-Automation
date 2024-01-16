# Infrastructure as Code examples for Citrix®

A set of automation examples for Citrix DaaS in the main Cloud providers (AWS,GCP, Azure), using different set of tools and technologies, such as [Terraform](https://www.terraform.io), [Ansible](https://www.ansible.com) and [Packer](https://www.packer.io)

The instructions asume basic knowledge on VM creation on the related Cloud providers and understanding of IAM permissions, networking and Image creation.

## PACKER SCRIPTS

Packer Scripts are used to create consistent golden images accross infrastructure providers. The initial example creates an fresh image ready to be published through Citrix MCS.

### Prerequisites

1. Install Packer on your machine: https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
2. An active cloud account (AWS, Azure, GCP) with enough permissions to create services accounts.

### AWS configuration

1. Install the AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
2. Create a service account in AWS console with the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeyPair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

3. Generate a key/secret pair for the service account.
4. authenticate in the AWS CLI by running the following command:

```sh
aws configure
```

specify the Key, secret and region to use for the image creation.
