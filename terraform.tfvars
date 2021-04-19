# Change these
owner-email = "sven@confluent.io"
owner-name = "sven"
key-name = "sven-ireland-sa"
purpose = "bootcamp-prep"

# Do not touch these
region = "eu-west-1"
availability-zone = "eu-west-1a"
# aws-ami-id = "ami-0865a4c652f3cd82b"
# aws-ami-id = "ami-0559330dd60001b36" Ubuntu 20.04, Java 11, CP 6.1.1
aws-ami-id = "ami-0cb5710bf2336192d"

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
broker-instance-type = "t3a.large"
schema-instance-type = "t3a.large"
connect-instance-type = "t3a.large"
rest-instance-type = "t3a.large"
c3-instance-type = "t3a.large"
ksql-instance-type = "t3a.large"
client-instance-type = "t3a.large"

