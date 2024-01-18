# Infrastructure as Code examples for Citrix®

A set of automation examples for Citrix DaaS in the main Cloud providers (AWS,GCP, Azure), using different set of tools and technologies, such as [Terraform](https://www.terraform.io), [Ansible](https://www.ansible.com) and [Packer](https://www.packer.io)

The instructions asume basic knowledge on VM creation on the related Cloud providers and understanding of IAM permissions, networking and Image creation.

## PACKER SCRIPTS

Packer Scripts are used to create consistent golden images accross infrastructure providers. The initial example creates an fresh image ready to be published through Citrix MCS. This approach use an Ansible playbook to patch the VM, install prerequisites and deploy the Citrix VDA software automatically. Currently this playbook installs Citrix VDA 2203CU4.

### Prerequisites

1. Install Packer in your machine: https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
2. Install Ansible in your machine: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
3. install the ansible plugin for Packer 
```sh
packer plugins install github.com/hashicorp/ansible
```
3. An active cloud account (AWS, Azure, GCP) with enough permissions to create services accounts.
4. Clone this repository locally to your machine

### AWS configuration

1. Install the AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
2. Install the amazon packer plugin 
```sh
packer plugins install github.com/hashicorp/amazon
```
3. Create a service account in AWS console with the following permissions:

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

Specify the Key, secret and region to use for the image creation. The default region used in the packer script is us-east-1. if you want to use a different region open `packer/aws/variables.pkr.hcl` and modify the `region` default variable value.

5. move to the "aws" directory inside Packer

```sh
cd packer/aws
```

6. Run the packer build command to start the image building process.

```sh
packer build .
```

The process will take around 20 minutes to complete, the following tasks are performed through Packer and Ansible:

- Creates an Windows Server 2022 EC2 instance in the specified region (us-east-1 by default) and wait to boot. Instances are deployed in the default VPC and default subnet right now. Support for customized VPCs will be added in future commits. 
- Uses the script detailed in `packer/aws/scripts/SetUpWinRM.ps1` as [user data script](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-user-data.html) to configure and enable WinRM communicator to connect to the instance. More information about [WinRM](https://developer.hashicorp.com/packer/docs/communicators/winrm)
- Waits for the instance to boot and WinRM to become available.
- Connects to the instance and run the ansible playbook detailed in `packer/playbooks/golden_vda_provisioning.yml`
- Runs the playbook steps detailed before.
- Shutdown the instance and create an AMI from it.
- Clean up the environment.

7. After the process finishes, you should expect to see an AMI in your AWS account with the format `golden-image-aws-{{timestamp}}`, with `timestamp` being the creation time. This image is ready to be used as a golden image with Citrix MCS. 

### Azure Configuration
1. Install the amazon packer plugin 
```sh
packer plugins install github.com/hashicorp/azure
```
2. Create a Service Principal with `contributor` access to the subscription where you want to deploy the image
3. Create a Secret for the Principal and save the secret value. 
4. move to the "azure" directory inside Packer

```sh
cd packer/azure
```
4. run the packer build command specifying the `client_id`, `client_secret`, `subscription_id` and `tenant_id` variables for the service principal authentication

```sh
packer build -var client_id={CLIENT_ID} -var client_secret={CLIENT_SECRET} -var subscription_id={SUBSCRIPTION_ID} -var tenant_id={TENANT_ID} .
```

The process will take around 20 minutes to complete, the following tasks are performed through Packer and Ansible:
- Creates a resource group named "packer_images"
- Creates a VM instance in the resource group using the `win11-22h2-avd` image with the `Standard_D2s_v4` instance size. This is hardcoded right now but can be modified in the file located in `packer/azure/azure-windows.pkr.hcl`. For the purpose of the example it is recommended to keep the current config. 
- Waits for the instance to boot and WinRM to become available. 
- Connects to the instance and run the ansible playbook detailed in `packer/playbooks/golden_vda_provisioning.yml`
- Runs the playbook steps detailed before.
- Shutdown the instance and create an Image from it.
- Clean up the environment.

7. After the process finishes, you should expect to see an Image in your Azure account with the format `packer-azure-{{timestamp}}`, with `timestamp` being the creation time. This image is ready to be used as a golden image with Citrix MCS. 

### Google Cloud instructions. 
1. Install the Google Cloud packer plugin 
```sh
packer plugins install github.com/hashicorp/googlecompute
```
2. Create a Service account and grant the `Compute Engine Instance Admin (v1)` and `Service Account User` roles. 
3. Generate a JSON Key for the service account. 
4. Set the Environment Variable `GOOGLE_APPLICATION_CREDENTIALS` to point to the path of the service account key.
5. Create a firewall rule in the VPC to allow the TCP port 5986 for WinRM traffic, you can set this through the [console](https://console.cloud.google.com/networking/firewalls/list) or run the following command with the gcloud CLI:
```sh
gcloud compute firewall-rules create allow-winrm --allow tcp:5986
```
6. move to the GCP directory inside Packer 
```sh
cd packer/gcp
```

7. Run the packer build command specifying the `project_id` variable
```sh
packer build -var project_id={PROJECT_ID} .
```

The process will take around 20 minutes to complete, the following tasks are performed through Packer and Ansible:
- Creates a Windows Server 2022 instance in the `us-central1-a` zone, with a machine type of `n1-stantard-2`.  This is hardcoded right now but can be modified in the file located in `packer/gcp/gcp-windows.pkr.hcl`.
- A specialized script is ran at the first boot to enable access through WinRM to the Instance.
- Waits for the instance to boot and WinRM to become available. 
- Connects to the instance and run the ansible playbook detailed in `packer/playbooks/golden_vda_provisioning.yml`
- Runs the playbook steps detailed before.
- Shutdown the instance and create an Image from it.
- Clean up the environment.

8. After the process finishes, you should expect to see an Image in your GCP account with the format `packer-{{timestamp}}`, with `timestamp` being the creation time. This image is ready to be used as a golden image with Citrix MCS. 


