// Copyright 2020 Sven Erik Knop sven@confluent.io
// All rights reserved

// Variables

variable "region" {
  default = "eu-west-1"
}

variable "availability-zone" {
  default = "eu-west-1a"
}

variable "owner-name" {
  default = "Sven Erik Knop"
}

variable "owner-email" {
 default = "sven@confluent.io"
}

variable "purpose" {
  default = "Bootcamp"
}

variable "key-name" {
  default = "sven-bootcamp"
}

variable "zk-count" {
}

variable "broker-count" {
}

variable "connect-count" {
  default = 0
}

variable "schema-count" {
  default = 0
}

variable "rest-count" {
  default = 0
}

variable "c3-count" {
  default = 0
}

variable "ksql-count" {
  default = 0
}

variable "zk-instance-type" {
  default = "t3a.large"
}

variable "broker-instance-type" {
  default = "t3a.large"
}

variable "schema-instance-type" {
  default = "t3a.large"
}

variable "connect-instance-type" {
  default = "t3a.large"
}

variable "rest-instance-type" {
  default = "t3a.large"
}

variable "c3-instance-type" {
  default = "t3a.large"
}

variable "ksql-instance-type" {
  default = "t3a.large"
}

variable "client-instance-type" {
  default = "t3a.large"
}

variable "hosted-zone-id" {
}

// Provider

provider "aws" {
  region     = var.region

  default_tags {
    tags = {
      Owner_Name = var.owner-name
      Owner_Email = var.owner-email
      purpose = var.purpose
    }
  }
}

variable "aws-ami-id"  {
  default = "ami-0cb5710bf2336192d"
}

variable "linux-user" {
  default = "ubuntu" // ec2-user
}

variable "vpc-id" {
  default = "vpc-04fe6b6f949db5d53"
}

variable "subnet-id" {
  default = "subnet-05f5d9abc3eb10caf"
}

variable "vpc-security-group-ids" {
  default = ["sg-081ef3ae3505577b4", "sg-0e2f40f9072de83ae"]
}

// Search for available availability zones (say it quickly three times)

//data "aws_availability_zones" "available" {
//  state = "available"
//}

// vpc_id vpc-047944e470c1d51db

// Resources

resource "aws_instance" "zookeepers" {
  count         = var.zk-count
  ami           = var.aws-ami-id
  instance_type = var.zk-instance-type
  availability_zone = var.availability-zone
  key_name = var.key-name

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "${var.owner-name}-zookeeper-${count.index}-${var.availability-zone}"
    description = "zookeeper nodes - Managed by Terraform"
    role = "zookeeper"
    zookeeperid = count.index
    Schedule = "zookeeper-mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "zookeepers-${var.region}"
  }

  subnet_id = var.subnet-id
  vpc_security_group_ids = var.vpc-security-group-ids
  associate_public_ip_address = true
}

resource "aws_route53_record" "zookeepers" {
  count = var.zk-count
  zone_id = var.hosted-zone-id
  name = "zookeeper-${count.index}.${var.owner-name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.zookeepers.*.private_ip, count.index)}"]
}

resource "aws_instance" "brokers" {
  count         = var.broker-count
  ami           = var.aws-ami-id
  instance_type = var.broker-instance-type
  availability_zone = var.availability-zone
  # security_groups = ["${var.security_group}"]
  key_name = var.key-name

  root_block_device {
    volume_size = 1000 # 1TB
  }

  tags = {
    Name = "${var.owner-name}-broker-${count.index}-${var.availability-zone}"
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

  subnet_id = var.subnet-id
  vpc_security_group_ids = var.vpc-security-group-ids
  associate_public_ip_address = true
}

resource "aws_route53_record" "brokers" {
  count = var.broker-count
  zone_id = var.hosted-zone-id
  name = "kafka-${count.index}.${var.owner-name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.brokers.*.private_ip, count.index)}"]
}

resource "aws_instance" "connect-cluster" {
  count         = var.connect-count
  ami           = var.aws-ami-id
  instance_type = var.connect-instance-type
  availability_zone = var.availability-zone
  key_name = var.key-name
  tags = {
    Name = "${var.owner-name}-connect-${count.index}-${var.availability-zone}"
    description = "Connect nodes - Managed by Terraform"
    role = "connect"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "connect-${var.region}"
  }

  root_block_device {
    volume_size = 100 # 1TB
  }

  subnet_id = var.subnet-id
  vpc_security_group_ids = var.vpc-security-group-ids
  associate_public_ip_address = true
}

resource "aws_route53_record" "connect-cluster" {
  count = var.connect-count
  zone_id = var.hosted-zone-id
  name = "connect-${count.index}.${var.owner-name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.connect-cluster.*.private_ip, count.index)}"]
}

resource "aws_instance" "schema" {
  count         = var.schema-count
  ami           = var.aws-ami-id
  instance_type = var.schema-instance-type
  availability_zone = var.availability-zone
  key_name = var.key-name
  tags = {
    Name = "${var.owner-name}-schema-${count.index}-${var.availability-zone}"
    description = "Schema nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  root_block_device {
    volume_size = 100 # 1TB
  }

  subnet_id = var.subnet-id
  vpc_security_group_ids = var.vpc-security-group-ids
  associate_public_ip_address = true
}

resource "aws_route53_record" "schema" {
  count = var.schema-count
  zone_id = var.hosted-zone-id
  name = "schema-${count.index}.${var.owner-name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.schema.*.private_ip, count.index)}"]
}

resource "aws_instance" "control-center" {
  count         = var.c3-count
  ami           = var.aws-ami-id
  instance_type = var.c3-instance-type
  availability_zone = var.availability-zone
  key_name = var.key-name

  root_block_device {
    volume_size = 1000 # 1TB
  }

  tags = {
    Name = "${var.owner-name}-control-center-${count.index}-${var.availability-zone}"
    description = "Control Center nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  subnet_id = var.subnet-id
  vpc_security_group_ids = var.vpc-security-group-ids
  associate_public_ip_address = true
}

resource "aws_route53_record" "control-center" {
  count = var.c3-count
  zone_id = var.hosted-zone-id
  name = "controlcenter-${count.index}.${var.owner-name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.control-center.*.private_ip, count.index)}"]
}

resource "aws_instance" "rest" {
  count         = var.rest-count
  ami           = var.aws-ami-id
  instance_type = var.rest-instance-type
  availability_zone = var.availability-zone
  key_name = var.key-name

  root_block_device {
    volume_size = 100 # 1TB
  }

  tags = {
    Name = "${var.owner-name}-rest-${count.index}-${var.availability-zone}"
    description = "Rest nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  subnet_id = var.subnet-id
  vpc_security_group_ids = var.vpc-security-group-ids
  associate_public_ip_address = true
}

resource "aws_route53_record" "rest" {
  count = var.rest-count
  zone_id = var.hosted-zone-id
  name = "rest-${count.index}.${var.owner-name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.rest.*.private_ip, count.index)}"]
}

resource "aws_instance" "ksql" {
  count         = var.ksql-count
  ami           = var.aws-ami-id
  instance_type = var.ksql-instance-type
  availability_zone = var.availability-zone
  key_name = var.key-name

  root_block_device {
    volume_size = 1000 # 1TB
  }

  tags = {
    Name = "${var.owner-name}-ksql-${count.index}-${var.availability-zone}"
    description = "Rest nodes - Managed by Terraform"
    role = "schema"
    Schedule = "mon-8am-fri-6pm"
    sshUser = var.linux-user
    region = var.region
    role_region = "schema-${var.region}"
  }

  subnet_id = var.subnet-id
  vpc_security_group_ids = var.vpc-security-group-ids
  associate_public_ip_address = true
}

resource "aws_route53_record" "ksql" {
  count = var.ksql-count
  zone_id = var.hosted-zone-id
  name = "ksql-${count.index}.${var.owner-name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.ksql.*.private_ip, count.index)}"]
}

// Output

output "zookeeper_private_dns" {
  value = [aws_instance.zookeepers.*.private_dns]
}

output "broker_private_dns" {
  value = [aws_instance.brokers.*.private_dns]
}

output "connect_private_dns" {
  value = [aws_instance.connect-cluster.*.private_dns]
}

output "schema_private_dns" {
  value = [aws_instance.schema.*.private_dns]
}

output "control_center_private_dns" {
  value = [aws_instance.control-center.*.private_dns]
}

output "rest_private_dns" {
  value = [aws_instance.rest.*.private_dns]
}

output "ksql_private_dns" {
  value = [aws_instance.ksql.*.private_dns]
}


# cluster data
output "cluster_data" {
  value = {
    "ssh_username" = var.linux-user
    "ssh_key" = var.key-name
  }
}
