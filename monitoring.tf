# Creates prometheus and grafana instances for students
# They still need to be provisioned

resource "random_integer" "monitoring-id" {
  min = 0
  max = length(var.public-subnet-id) - 1
}

locals {
  monitoring-placement = random_integer.monitoring-id.result
}

resource "aws_instance" "prometheus" {
  count         = var.create-monitoring-instances ? 1 : 0
  ami           = var.aws-ami-id
  instance_type = var.prometheus-instance-type
  key_name = var.key-name

  root_block_device {
    volume_size = 64
  }

  tags = {
    Name = "${var.dns-suffix}-prometheus"
    description = "Prometheus node - Managed by Terraform"
    role = "prometheus"
    Schedule = "zookeeper-mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
  }

  subnet_id = var.public-subnet-id[local.monitoring-placement]
  availability_zone = var.availability-zone[local.monitoring-placement]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id, var.external-vpc-security-group-id ]
  associate_public_ip_address = true
}

resource "aws_route53_record" "prometheus" {
  count = var.create-monitoring-instances ? 1 : 0
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "prometheus.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.prometheus.*.private_ip, count.index)]
}


resource "aws_instance" "grafana" {
  count         = var.create-monitoring-instances ? 1 : 0
  ami           = var.aws-ami-id
  instance_type = var.grafana-instance-type
  key_name = var.key-name

  root_block_device {
    volume_size = 64
  }

  tags = {
    Name = "${var.dns-suffix}-grafana"
    description = "Grafana node - Managed by Terraform"
    role = "grafana"
    Schedule = "zookeeper-mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
  }

  subnet_id = var.public-subnet-id[local.monitoring-placement]
  availability_zone = var.availability-zone[local.monitoring-placement]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id, var.external-vpc-security-group-id ]
  associate_public_ip_address = true
}

resource "aws_route53_record" "grafana" {
  count = var.create-monitoring-instances ? 1 : 0
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "grafana.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.grafana.*.private_ip, count.index)]
}
