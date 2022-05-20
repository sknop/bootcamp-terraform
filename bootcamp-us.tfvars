# Change these
owner-email = "vnarayanan@confluent.io"
owner-name = "venky"
key-name = "venkybootcampawsoregon"
purpose = "bootcamp-prep"

# Change sg-024f460997cfcae32 to your SG
vpc-security-group-ids = ["sg-0530d3323337d2d22", "sg-024f460997cfcae32"] # Do not change sg-0530d3323337d2d22 (Required)

# Touch these only if you know what you are doing
region = "us-west-2"
availability-zone = "us-west-2b"
hosted-zone-id = "Z3JO7K0DOCUBEL"
vpc-id = "vpc-047944e470c1d51db"
subnet-id = []

aws-ami-id = "ami-01d2e4357acf95f63" # Ubuntu 18.04 LTS CP 6.2.0 AMI; Use ami-02701bcdc5509e57b for Ubuntu 18.04 LTS base

zk-count = 3
broker-count = 5
connect-count = 2
schema-count = 2
rest-count = 1
ksql-count = 2
c3-count = 1

zk-instance-type = "t3a.large"
broker-instance-type = "t3a.large"
schema-instance-type = "t3.medium"
connect-instance-type = "t3a.large"
rest-instance-type = "t3.medium"
c3-instance-type = "t3a.large"
ksql-instance-type = "t3a.large"
client-instance-type = "t3.medium"
