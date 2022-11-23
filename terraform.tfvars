# Change these
owner-email = "sven@confluent.io"
owner-name = "Sven Erik Knop"
dns-suffix = "sven"
key-name = "bootcamp-emea-key"
purpose = "Bootcamp EMEA"

# Adjust these to your trainer's instructions
region = "eu-west-1"
aws-ami-id = "ami-09152cf3ca0526d32"

zk-count = 3
broker-count = 4
connect-count = 2
schema-count = 2
rest-count = 0
ksql-count = 2
c3-count = 1

create-monitoring-instances = true

internal-vpc-security-group-id = "sg-0da2df059c6a02c99"
external-vpc-security-group-id = "sg-0a162b57a7fc4fc6b"
vpc-id = "vpc-08bdc92a356608549"
availability-zone = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
subnet-id = ["subnet-0a0a2d1df91e307d9", "subnet-0c9e93e3d38a504f9", "subnet-0b912f5655f9b853e"]
public-subnet-id = ["subnet-0ab31422173f09594", "subnet-0374dbf2e1013cded", "subnet-0e60f504f82eb58d7",]

zk-instance-type = "t3a.medium"
broker-instance-type = "r5.xlarge"
schema-instance-type = "t3a.medium"
connect-instance-type = "t3a.large"
rest-instance-type = "t3a.medium"
c3-instance-type = "r5.xlarge"
ksql-instance-type = "t3a.large"
client-instance-type = "t3a.large"

hosted-zone-id = "Z031101315QZYPTJNNUTX"

