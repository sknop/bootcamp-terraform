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
broker-count = 3
connect-count = 2
schema-count = 2
rest-count = 1
ksql-count = 2
c3-count = 1

vpc-security-group-ids = ["sg-05125a76d7bf3be1f"]
vpc-id = "vpc-0306bb7f5c8f2c710"
subnet-id = []

zk-instance-type = "t3a.large"
broker-instance-type = "t3a.large"
schema-instance-type = "t3.medium"
connect-instance-type = "t3a.large"
rest-instance-type = "t3.medium"
c3-instance-type = "t3a.large"
ksql-instance-type = "t3a.large"
client-instance-type = "t3.medium"

hosted-zone-id = "Z0928738PJ9GXZ2WNQCH"
