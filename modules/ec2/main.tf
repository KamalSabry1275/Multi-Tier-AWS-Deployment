data "aws_ami" "ami" {
  most_recent = true
  owners      = var.ami_owner

  filter {
    name   = "name"
    values = var.ami_name_filter
  }

  filter {
    name   = "architecture"
    values = var.ami_architecture
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags      = merge(var.extra_tags, { Name : var.instance_name })
  user_data = <<-EOF
                ${var.user_data}
                EOF

}

resource "aws_security_group" "sg" {
  name   = "${var.instance_name} - sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.instance_name} - sg"
  }

  dynamic "ingress" {
    for_each = var.inbound
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = var.outbound
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }
}