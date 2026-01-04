# TestInstance_Terraformed
Terraform modules for deploying an empty EC2 instance

Uses Terraform to deploy an AWS EC2 instance, then outputs links to SSH into the instance, and one for port 5000.
Run the link from the same place you run the Terraform plan, and you'll be in a fresh Ubuntu instance to use at your leisure!

Module includes:
- EC2 instance using Ubuntu 22.04
- Private Key and Key Pair saved locally for SSH access
- Security Group with an ingress rule allowing access to ports 22 and 5000 from the IP you run the Terraform plan from, and with open egress

The "defaultVpc" version of the module only deploys the EC2 instance, Key Pair, and Security Group, which will use the default VPC and one of its subnets for the region.

The "fullNetStack" version of the module creates an independent networking setup for the app by also deploying a VPC, public subnet, Internet Gateway (IGW), and route table.


*** Requirements
- An AWS Account
- AWS CLI
- Terraform
- That should be it!


Notes
- Deafult region is us-west-2
- Security Group allows SSH access from your IP; it does not allow any other ingress
- Output includes a link to SSH into the machine from the same place you run the TF module, as well as one for port 5000 for any apps
