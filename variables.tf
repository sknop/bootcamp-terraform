# Variables are declared here

variable "region" {
  default = "eu-west-1"
}

variable "availability-zone" {
  type = list(string)
}

variable "owner-name" {
  default = "Sven Erik Knop"
}

variable "owner-email" {
  default = "sven@confluent.io"
}

variable "dns-suffix" {
  default = "changeme"
  description = "Suffix for DNS entry in Route 53. No spaces!"
}

variable "purpose" {
  default = "Bootcamp"
}

variable "key-name" {
  default = "sven-bootcamp"
}

variable "zk-count" {
  type = number
}

variable "broker-count" {
  type = number
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

variable "create-monitoring-instances" {
  description = "If set, will create Prometheus and Grafana instances"
  type = bool
  default = false
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

variable "prometheus-instance-type" {
  default = "t3a.large"
}

variable "grafana-instance-type" {
  default = "t3a.large"
}

variable "hosted-zone-id" {
}

variable "aws-ami-id"  {
}

variable "linux-user" {
  default = "ubuntu" // ec2-user
}

variable "vpc-id" {
}

variable "public-subnet-id" {
  type = list(string)
}

variable "subnet-id" {
  type = list(string)
}

variable "internal-vpc-security-group-id" {
  type = string
}

variable "external-vpc-security-group-id" {
  type = string
}
