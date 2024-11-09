# bootcamp-terraform

Confluent Bootcamp conform terraform scripts and configuration file.

This Terraform script should be run on your local computer/laptop as part of the CP bootcamp.
The script will create a range of instances that will then be populated via cp-ansible with a Confluent cluster. 

# Instructions

Clone this repository if not already done so.

        cp terraform.tfvars.template terraform.tfvars
        vi terraform.tfvars # you can also use nano or any another editor
        terraform init
        terraform plan      # this is just for verification and optional
        terraform apply

The output can be recalled with the command

        terraform output

## terraform.tfvars

This file has three sections:

### Change these
    owner-email = "sven@confluent.io"
    owner-name = "Sven Erik Knop"
    dns-suffix = "your nickname here"
    key-name = "bootcamp-emea-key"
    purpose = "Bootcamp EMEA"
    cflt_managed_id = "sven"
    cflt_service = "EMEA"

`dns-suffix` will be used to give each instance a symbolic name in the DNS server of AWS, Route53. For example, 
with this entry 

    dns-suffix = "sven"

entries in the form

    kafka-0.sven
    kafka-1.sven
    controller-0.sven

will be created.

### Adjust these to your trainer's instructions
    region = "eu-west-1"
    aws-ami-id = "ami-09152cf3ca0526d32"
    
    hosted-zone-id = "Z031101315QZYPTJNNUTX"
    internal-vpc-security-group-id = "sg-0da2df059c6a02c99"
    external-vpc-security-group-id = "sg-0a162b57a7fc4fc6b"
    vpc-id = "vpc-08bdc92a356608549"
    availability-zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    private-subnet-ids = ["subnet-0a0a2d1df91e307d9", "subnet-0c9e93e3d38a504f9", "subnet-0b912f5655f9b853e"]
    public-subnet-ids = ["subnet-0ab31422173f09594", "subnet-0374dbf2e1013cded", "subnet-0e60f504f82eb58d7",]
    
    zk-count = 0
    controller-count = 3
    broker-count = 3
    connect-count = 2
    schema-count = 2
    rest-count = 0
    ksql-count = 2
    c3-count = 1
    
    create-monitoring-instances = true

These entries should be populated with the output of [bootcamp-vpc](https://github.com/sknop/bootcamp-vpc), either 
your own VPC or the one shared with you by your instructor or colleague who created the bootcamp VPC.

### Leave these alone unless you know what you are doing

The following regions need to change instances t3a --> t3, because t3a is not available in that region yet

- Hyderabad (ap-south-2)
- Spain (eu-south-2)
- UAE (me-central-1)


    zk-instance-type = "t3a.medium"
    controller-instance-type = "t3a.medium"
    broker-instance-type = "r5.xlarge"
    schema-instance-type = "t3a.medium"
    connect-instance-type = "t3a.large"
    rest-instance-type = "t3a.medium"
    c3-instance-type = "r5.xlarge"
    ksql-instance-type = "t3a.large"
    client-instance-type = "t3a.large"
    prometheus-instance-type = "t3a.medium"
    grafana-instance-type = "t3a.medium"

The instances sizes are usually sufficient for a one-week CP bootcamp. Keep in mind that if you increase the sizes, 
you will incur higher costs in AWS.
