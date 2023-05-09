// Copyright 2020,2022 Sven Erik Knop sven@confluent.io
// All rights reserved

// Provider

provider "aws" {
  region     = var.region

  default_tags {
    tags = {
      owner_name = var.owner-name
      owner_email = var.owner-email
      purpose = var.purpose
    }
  }
}

// Resources

resource "aws_instance" "zookeepers" {
  count         = var.zk-count
  ami           = var.aws-ami-id
  instance_type = var.zk-instance-type
  key_name = var.key-name

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "${var.dns-suffix}-zookeeper-${count.index}"
    description = "zookeeper nodes - Managed by Terraform"
    role = "zookeeper"
    zookeeperid = count.index
    Schedule = "zookeeper-mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "zookeepers-${var.region}"
  }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "zookeepers" {
  count = var.zk-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "zookeeper-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.zookeepers.*.private_ip, count.index)]
}

resource "aws_instance" "controllers" {
  count         = var.controller-count
  ami           = var.aws-ami-id
  instance_type = var.controller-instance-type
  key_name = var.key-name

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "${var.dns-suffix}-controller-${count.index}"
    description = "Kafka Controller nodes - Managed by Terraform"
    role = "controller"
    controller_id = count.index
    Schedule = "zookeeper-mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "controllers-${var.region}"
  }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "controllers" {
  count = var.controller-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "controller-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.controllers.*.private_ip, count.index)]
}

resource "aws_instance" "brokers" {
  count         = var.broker-count
  ami           = var.aws-ami-id
  instance_type = var.broker-instance-type
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]

    # security_groups = ["${var.security_group}"]
  key_name = var.key-name

  root_block_device {
    volume_size = 64 # 64 GB
  }

  tags = {
    Name = "${var.dns-suffix}-broker-${count.index}"
    description = "broker nodes - Managed by Terraform"
    nice-name = "kafka-${count.index}"
    big-nice-name = "follower-kafka-${count.index}"
    brokerid = count.index
    role = "broker"
    sshUser = var.linux-user
    # sshPrivateIp = true // this is only checked for existence, not if it's true or false by terraform.py (ati)
    createdBy = "terraform"
    Schedule = "kafka-mon-8am-fri-6pm"
    # ansible_python_interpreter = "/usr/bin/python3"
    #EntScheduler = "mon,tue,wed,thu,fri;1600;mon,tue,wed,thu;fri;sat;0400;"
    region = var.region
    role_region = "brokers-${var.region}"
  }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "brokers" {
  count = var.broker-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "kafka-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.brokers.*.private_ip, count.index)]
}

resource "aws_instance" "connect-cluster" {
  count         = var.connect-count
  ami           = var.aws-ami-id
  instance_type = var.connect-instance-type
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]
  key_name = var.key-name
  tags = {
    Name = "${var.dns-suffix}-connect-${count.index}"
    description = "Connect nodes - Managed by Terraform"
    role = "connect"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "connect-${var.region}"
  }

  root_block_device {
    volume_size = 20 # 20 GB
  }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "connect-cluster" {
  count = var.connect-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "connect-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.connect-cluster.*.private_ip, count.index)]
}

resource "aws_instance" "schema" {
  count         = var.schema-count
  ami           = var.aws-ami-id
  instance_type = var.schema-instance-type
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]
  key_name = var.key-name
  tags = {
    Name = "${var.dns-suffix}-schema-${count.index}"
    description = "Schema nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  root_block_device {
    volume_size = 20 # 20 GB
 }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "schema" {
  count = var.schema-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "schema-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.schema.*.private_ip, count.index)]
}

resource "aws_instance" "control-center" {
  count         = var.c3-count
  ami           = var.aws-ami-id
  instance_type = var.c3-instance-type
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]
  key_name = var.key-name

  root_block_device {
    volume_size = 64 # 64GB
  }

  tags = {
    Name = "${var.dns-suffix}-control-center-${count.index}"
    description = "Control Center nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "control-center" {
  count = var.c3-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "controlcenter-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.control-center.*.private_ip, count.index)]
}

resource "aws_instance" "rest" {
  count         = var.rest-count
  ami           = var.aws-ami-id
  instance_type = var.rest-instance-type
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]

  key_name = var.key-name

  root_block_device {
    volume_size = 20 # 20 GB
  }

  tags = {
    Name = "${var.dns-suffix}-rest-${count.index}"
    description = "Rest nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "rest" {
  count = var.rest-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "rest-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.rest.*.private_ip, count.index)]
}

resource "aws_instance" "ksql" {
  count         = var.ksql-count
  ami           = var.aws-ami-id
  instance_type = var.ksql-instance-type
  availability_zone = var.availability-zones[count.index % length(var.availability-zones)]
  key_name = var.key-name

  root_block_device {
    volume_size = 64 # 64 GB
  }

  tags = {
    Name = "${var.dns-suffix}-ksql-${count.index}"
    description = "Rest nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  subnet_id = var.private-subnet-ids[count.index % length(var.private-subnet-ids)]
  vpc_security_group_ids = [ var.internal-vpc-security-group-id ]
  associate_public_ip_address = false
}

resource "aws_route53_record" "ksql" {
  count = var.ksql-count
  allow_overwrite = true
  zone_id = var.hosted-zone-id
  name = "ksql-${count.index}.${var.dns-suffix}"
  type = "A"
  ttl = "300"
  records = [element(aws_instance.ksql.*.private_ip, count.index)]
}

