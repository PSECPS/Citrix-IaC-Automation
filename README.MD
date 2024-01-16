# Infrastructure as Code examples for Citrix®

A set of automation examples for Citrix DaaS in the main Cloud providers (AWS,GCP, Azure), using different set of tools and technologies, such as [Terraform](https://www.terraform.io), [Ansible](https://www.ansible.com) and [Packer](https://www.packer.io)

The instructions asume basic knowledge on VM creation on the related Cloud providers and understanding of IAM permissions, networking and Image creation.

## PACKER SCRIPTS

Packer Scripts are used to create consistent golden images accross infrastructure providers. The initial example creates an fresh image ready to be published through Citrix MCS. This approach use an Ansible playbook to patch the VM, install prerequisites and deploy the Citrix VDA software automatically. Currently this playbook installs Citrix VDA 2203CU4.

### Prerequisites

1. Install Packer in your machine: https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
2. Install Ansible in your machine: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
3. An active cloud account (AWS, Azure, GCP) with enough permissions to create services accounts.
4. Clone this repository locally to your machine

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

specify the Key, secret and region to use for the image creation. The default region used in the packer script is us-east-1. if you want to use a different region open `packer/aws/variables.pkr.hcl` and modify the `region` default variable value 5. move to the "aws" directory inside Packer

```sh
cd packer/aws
```

6. Run the packer build command to start the image building process.

```sh
packer build .
```

The process will take around 20 minutes to complete, the following tasks are performed through Packer and Ansible:

- Create an EC2 instance in the specified region (us-east-1 by default) and wait to boot.
- use the script detailed in `packer/aws/scripts/SetUpWinRM.ps1` as [user data script](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-user-data.html) to configure and enable WinRM communicator to connect to the instance. More information about [WinRM](https://developer.hashicorp.com/packer/docs/communicators/winrm)
- Wait for the instance to boot and WinRM to become available.
- Connect to the instance and run the ansible playbook detailed in `packer/playbooks.golden_vda_provisioning.yml`
- Run the playbook steps detailed before.
- Shutdown the instance and create an AMI from it.
- Clean up the environment.

7. After the process finishes, you should expect to see an AMI in your AWS account with the format `$golden-image-aws-{{timestamp}}`, with `timestamp` being the creation time.
