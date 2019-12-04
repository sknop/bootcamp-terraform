// Copyright 2019 Sven Erik Knop sven@confluent.io
// All rights reserved

// Variables

variable "region" {
  default = "us-west-2"
}

variable "owner" {
  default = "sek"
}

variable "key_name" {
  default = "bootcamp"
}

variable "zk-count" {
  default = 1
}

variable "broker-count" {
  default = 1
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

// instance types

locals {
  zk-instance-type = "t3a.large"
  broker-instance-type = "t3a.large"
  schema-instance-type = "t3a.large"
  connect-instance-type = "t3a.large"
  rest-instance-type = "t3a.large"
  c3-instance-type = "t3a.large"
  ksql-instance-type = "t3a.large"
  client-instance-type = "t3a.large"
}

// Provider

provider "aws" {
  profile    = "default"
  region     = "${var.region}"
}

// Search for AMI rather than hard coding its ID

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

// Search for available availibility zones (say it quickly three times)

data "aws_availability_zones" "available" {
  state = "available"
}

// vpc_id vpc-047944e470c1d51db

// Resources

resource "aws_instance" "zookeepers" {
  count         = "${var.zk-count}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${local.zk-instance-type}"
  availability_zone = "us-west-2a"
  key_name = "${var.key_name}"

  tags = {
    Name = "${var.owner}-zookeeper-${count.index}-us-west-2a"
    description = "zookeeper nodes - Managed by Terraform"
    role = "zookeeper"
    zookeeperid = "${count.index}"
    Owner = "${var.owner}"
    sshUser = "centos"
    region = "${var.region}"
    role_region = "zookeepers-${var.region}"
  }

  subnet_id = "subnet-0b7590362ae2e19da"
  vpc_security_group_ids = ["sg-0391972943fdd1bb5", "sg-086857c30f12a4858"]
}

resource "aws_instance" "brokers" {
  count         = "${var.broker-count}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${local.broker-instance-type}"
  availability_zone = "us-west-2a"
  # security_groups = ["${var.security_group}"]
  key_name = "${var.key_name}"
  root_block_device {
    volume_size = 1000 # 1TB
  }
  tags = {
    Name = "${var.owner}-broker-${count.index}-us-west-2a"
    description = "broker nodes - Managed by Terraform"
    nice-name = "kafka-${count.index}"
    big-nice-name = "follower-kafka-${count.index}"
    brokerid = "${count.index}"
    role = "broker"
    owner = "${var.owner}"
    sshUser = "ubuntu"
    # sshPrivateIp = true // this is only checked for existence, not if it's true or false by terraform.py (ati)
    createdBy = "terraform"
    # ansible_python_interpreter = "/usr/bin/python3"
    #EntScheduler = "mon,tue,wed,thu,fri;1600;mon,tue,wed,thu;fri;sat;0400;"
    region = "${var.region}"
    role_region = "brokers-${var.region}"
  }

  subnet_id = "subnet-0b7590362ae2e19da"
  vpc_security_group_ids = ["sg-0391972943fdd1bb5", "sg-086857c30f12a4858"]
}

resource "aws_instance" "connect-cluster" {
  count         = "${var.connect-count}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${local.connect-instance-type}"
  availability_zone = "us-west-2a"
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.owner}-connect-${count.index}-us-west-2a"
    description = "Connect nodes - Managed by Terraform"
    role = "connect"
    Owner = "${var.owner}"
    sshUser = "ubuntu"
    region = "${var.region}"
    role_region = "connect-${var.region}"
  }

  subnet_id = "subnet-0b7590362ae2e19da"
  vpc_security_group_ids = ["sg-0391972943fdd1bb5", "sg-086857c30f12a4858"]
}

resource "aws_instance" "schema" {
  count         = "${var.schema-count}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${local.schema-instance-type}"
  availability_zone = "us-west-2a"
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.owner}-schema-${count.index}-us-west-2a"
    description = "Schema nodes - Managed by Terraform"
    role = "schema"
    Owner = "${var.owner}"
    sshUser = "ubuntu"
    region = "${var.region}"
    role_region = "schema-${var.region}"
  }

  subnet_id = "subnet-0b7590362ae2e19da"
  vpc_security_group_ids = ["sg-0391972943fdd1bb5", "sg-086857c30f12a4858"]
}

resource "aws_instance" "control-center" {
  count         = "${var.c3-count}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${local.c3-instance-type}"
  availability_zone = "us-west-2a"
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.owner}-control-center-${count.index}-us-west-2a"
    description = "Control Center nodes - Managed by Terraform"
    role = "schema"
    Owner = "${var.owner}"
    sshUser = "ubuntu"
    region = "${var.region}"
    role_region = "schema-${var.region}"
  }

  subnet_id = "subnet-0b7590362ae2e19da"
  vpc_security_group_ids = ["sg-0391972943fdd1bb5", "sg-086857c30f12a4858"]
}

resource "aws_instance" "rest" {
  count         = "${var.rest-count}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${local.rest-instance-type}"
  availability_zone = "us-west-2a"
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.owner}-rest-${count.index}-us-west-2a"
    description = "Rest nodes - Managed by Terraform"
    role = "schema"
    Owner = "${var.owner}"
    sshUser = "ubuntu"
    region = "${var.region}"
    role_region = "schema-${var.region}"
  }

  subnet_id = "subnet-0b7590362ae2e19da"
  vpc_security_group_ids = ["sg-0391972943fdd1bb5", "sg-086857c30f12a4858"]
}

resource "aws_instance" "ksql" {
  count         = "${var.ksql-count}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${local.ksql-instance-type}"
  availability_zone = "us-west-2a"
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.owner}-ksql-${count.index}-us-west-2a"
    description = "Rest nodes - Managed by Terraform"
    role = "schema"
    Owner = "${var.owner}"
    sshUser = "ubuntu"
    region = "${var.region}"
    role_region = "schema-${var.region}"
  }

  subnet_id = "subnet-0b7590362ae2e19da"
  vpc_security_group_ids = ["sg-0391972943fdd1bb5", "sg-086857c30f12a4858"]
}

// Output

output "zookeeper_public_dns" {
  value = ["${aws_instance.zookeepers.*.public_dns}"]
}

output "broker_public_dns" {
  value = ["${aws_instance.brokers.*.tags.brokerid}","${aws_instance.brokers.*.public_dns}"]
}

output "connect_public_dns" {
  value = ["${aws_instance.connect-cluster.*.public_dns}"]
}

output "schema_public_dns" {
  value = ["${aws_instance.schema.*.public_dns}"]
}

output "control_center_public_dns" {
  value = ["${aws_instance.control-center.*.public_dns}"]
}

output "rest_public_dns" {
  value = ["${aws_instance.rest.*.public_dns}"]
}

output "ksql_public_dns" {
  value = ["${aws_instance.ksql.*.public_dns}"]
}
