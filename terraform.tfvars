# Change these
owner-email = "vnarayanan@confluent.io"
owner-name = "venky"
key-name = "venkybootcampawsoregon"
purpose = "bootcamp-prep"

region = "us-west-2"
availability-zone = "us-west-2b"
aws-ami-id = "ami-0fb65a3656895ad5c"

zk-count = 1
broker-count = 2
connect-count = 1
schema-count = 1
rest-count = 1
ksql-count = 1
c3-count = 1

vpc-security-group-ids = ["sg-0530d3323337d2d22", "sg-024f460997cfcae32"]
vpc-id = "vpc-047944e470c1d51db"
subnet-id = "subnet-064343a3fbf437eac"

zk-instance-type = "t3a.large"
broker-instance-type = "t3a.large"
schema-instance-type = "t3.medium"
connect-instance-type = "t3a.large"
rest-instance-type = "t3.medium"
c3-instance-type = "t3a.large"
ksql-instance-type = "t3a.large"
client-instance-type = "t3.medium"

