locals {
  subnet_id         = length(var.subnet_id) > 0 ? var.subnet_id : coalesce(data.aws_subnet_ids.default.ids...)
  ami_id            = length(var.ami_id) > 0 ? var.ami_id : data.aws_ami.focal.id
  vpc_id            = data.aws_subnet.self.vpc_id
  role_name         = "atlantis-${random_id.self.hex}"
  secgroup_name     = length(var.secgroup_id) <= 0 ? "atlantis-secgroup-${random_id.self.hex}" : ""
  security_group_id = length(var.secgroup_id) <= 0 ? aws_security_group.self[0].id : var.secgroup_id
  ec2_key_name      = length(var.public_key) > 0 ? "atlantis-keypair-${random_id.self.hex}" : var.key_name
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "self" {
  id = local.subnet_id
}

data "aws_ami" "focal" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "random_id" "self" {
  byte_length = 4
}

resource "aws_instance" "self" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = local.ec2_key_name
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [local.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.self.name

  tags = merge({ Name = "atlantis-server", ManagedBy = "terraform" }, var.tags)

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_disk_size
    encrypted   = true
  }

  depends_on = [aws_key_pair.self]
}

resource "aws_key_pair" "self" {
  count = length(var.public_key) > 0 ? 1 : 0

  key_name   = local.ec2_key_name
  public_key = var.public_key

  tags = {
    Name      = "atlantis-server-key-${random_id.self.hex}"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "self" {
  count = length(var.secgroup_id) <= 0 ? 1 : 0

  name        = local.secgroup_name
  description = "Security group to allow network inbound and outbound communication for Atlantis"
  vpc_id      = local.vpc_id

  tags = {
    Name      = local.secgroup_name
    ManagedBy = "terraform"
  }
}

resource "aws_security_group_rule" "allow_all" {
  count = length(var.secgroup_id) <= 0 ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.self[0].id
}

resource "aws_security_group_rule" "allow_ssh" {
  count = length(var.secgroup_id) <= 0 ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.self[0].id
}

resource "aws_security_group_rule" "allow_http" {
  count = length(var.secgroup_id) <= 0 ? 1 : 0

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.self[0].id
}

resource "aws_security_group_rule" "allow_https" {
  count = length(var.secgroup_id) <= 0 ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.self[0].id
}

resource "aws_iam_instance_profile" "self" {
  name = local.role_name
  role = aws_iam_role.atlantis.name
}

resource "aws_iam_role" "atlantis" {
  name               = local.role_name
  description        = "This role is specific for Atlantis"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json

  tags = {
    Name      = local.role_name
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "admin" {
  count = var.attach_admin_policy ? 1 : 0

  role       = aws_iam_role.atlantis.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_eip_association" "self" {
  instance_id   = aws_instance.self.id
  allocation_id = aws_eip.self.id
}

resource "aws_eip" "self" {
  vpc = true

  tags = {
    Name      = "atlantis-elastic-ip-${random_id.self.hex}"
    ManagedBy = "terraform"
  }
}