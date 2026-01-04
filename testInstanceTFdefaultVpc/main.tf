# --------------------------------------------------------------------
# Local variable for user IP address, and cleaning up VM IP for SSH url
# --------------------------------------------------------------------

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
  instanceIpAddress        = aws_instance.testerzInstance.public_ip
  dashedInstanceIpAddress = replace(local.instanceIpAddress, ".", "-")
}

# --------------------------------------------------------------------
# Create a Security Group and Ingress/Egress Rules
# --------------------------------------------------------------------

resource "aws_security_group" "testerzSecurityGroup" {
  name        = "Testerz_SecurityGroup"
  description = "Allow SSH access to 22 from user IP only"
  region      = var.aws_region

  tags = merge(
    var.tags,
    {
      Name = "Testerz_SecurityGroup"
    }
  )
}

# Create an Ingress rule allowing only local IP to access port 22
resource "aws_vpc_security_group_ingress_rule" "testerzSGIngress22" {
  region            = var.aws_region
  security_group_id = aws_security_group.testerzSecurityGroup.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Create an Ingress rule allowing only local IP to access port 5000
resource "aws_vpc_security_group_ingress_rule" "testerzSGIngress5000" {
  region            = var.aws_region
  security_group_id = aws_security_group.testerzSecurityGroup.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

# Create an Egress rule allowing all outbound traffic
resource "aws_vpc_security_group_egress_rule" "testerzSGEgressOpen" {
  region            = var.aws_region
  security_group_id = aws_security_group.testerzSecurityGroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# --------------------------------------------------------------------
# Create Private Key and Key Pair for SSH access, and save pem file locally
# --------------------------------------------------------------------

resource "tls_private_key" "testerzPrivateKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "testerzKeyPair" {
  key_name   = var.key_name
  region     = var.aws_region
  public_key = tls_private_key.testerzPrivateKey.public_key_openssh
}

resource "local_file" "testerzPrivate_key_pem" {
  filename        = var.private_key_path
  content         = tls_private_key.testerzPrivateKey.private_key_pem
  file_permission = "0400"
}

# --------------------------------------------------------------------
# Create EC2 instance connected to the networking resources created above
# --------------------------------------------------------------------

resource "aws_instance" "testerzInstance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  region                 = var.aws_region
  vpc_security_group_ids = [aws_security_group.testerzSecurityGroup.id]
  key_name               = aws_key_pair.testerzKeyPair.key_name

  associate_public_ip_address = var.associate_public_ip

  tags = merge(
    var.tags,
    {
      Name = "Testerz_Instance"
    }
  )
}