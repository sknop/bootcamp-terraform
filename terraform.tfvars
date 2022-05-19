# Change these
owner-email = "sven@confluent.io"
owner-name = "sven"
key-name = "sven-ireland-sa"
purpose = "bootcamp-prep"

# Do not touch these
region = "eu-west-1"
availability-zone = "eu-west-1a"
aws-ami-id = "ami-0d5c7dc1a2fd36a4b"

zk-count = 3
broker-count = 4
connect-count = 2
schema-count = 2
rest-count = 1
ksql-count = 2
c3-count = 1

vpc-security-group-ids = ["sg-055c8c07419910751"]
vpc-id = "vpc-08da1069e2646f90f"
subnet-id = "subnet-08ee5dfa7dff69142"

zk-instance-type = "t3a.large"
broker-instance-type = "r5.2xlarge"
schema-instance-type = "t3a.large"
connect-instance-type = "t3a.large"
rest-instance-type = "t3a.large"
c3-instance-type = "r5.2xlarge"
ksql-instance-type = "t3a.large"
client-instance-type = "t3a.large"

hosted-zone-id = "Z062492024YHYM5K442Z8"

