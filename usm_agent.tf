# Creates prometheus and grafana instances for students
# They still need to be provisioned

resource "random_integer" "usm-agent-id" {
  min = 0
  max = length(var.private-subnet-ids) - 1
}

locals {
  usm-agent-placement = random_integer.usm-agent-id.result
}

resource "aws_instance" "usm-agent" {
  count         = var.create-usm-agent-instance ? 1 : 0
  ami           = var.aws-ami-id
  instance_type = var.usm-agent-instance-type
  key_name = var.key-name

  root_block_device {
    volume_size = 64
  }

  tags = {
    Name = "${var.dns-suffix}-usm-agent"
    description = "USM Agent node - Managed by Terraform"
    role = "usm-agent"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    cflt_keep_until   = local.keep_until
  }

  volume_tags = {
    cflt_keep_until   = local.keep_until
  }

  subnet_id = var.private-subnet-ids[local.usm-agent-placement]
  availability_zone = var.availability-zones[local.usm-agent-placement]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "usm-agent" {
  count = var.create-usm-agent-instance ? 1 : 0
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "usm-agent.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.usm-agent.*.private_ip, count.index)]
}
