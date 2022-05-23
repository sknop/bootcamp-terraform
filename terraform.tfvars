# Change these
owner-email = "sven@confluent.io"
owner-name = "Sven Erik Knop"
dns-suffix = "sven"
key-name = "bootcamp-partner-key"
purpose = "bootcamp-prep"

# Do not touch these
region = "eu-west-1"
aws-ami-id = "ami-0d5c7dc1a2fd36a4b"

zk-count = 3
broker-count = 4
connect-count = 2
schema-count = 2
rest-count = 1
ksql-count = 2
c3-count = 1

vpc-security-group-ids = ["sg-01faa32b2b7f59b9c"]
vpc-id = "vpc-032661311f117158f"
availability-zone = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
subnet-id = ["subnet-01f6b834bb0ca7019", "subnet-0e03ebc6c8ac05ea5", "subnet-089e41d25af163bcb"]

zk-instance-type = "t3a.large"
broker-instance-type = "r5.2xlarge"
schema-instance-type = "t3a.large"
connect-instance-type = "t3a.large"
rest-instance-type = "t3a.large"
c3-instance-type = "r5.2xlarge"
ksql-instance-type = "t3a.large"
client-instance-type = "t3a.large"

hosted-zone-id = "Z04074374K4G0N8F19HI"

