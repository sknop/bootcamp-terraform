# bootcamp-terraform

Confluent Bootcamp conform terraform scripts and configuration file.

## preparation

- (optional) create a Python virtual environment
- `pip install -r requirements.txt` 

## convert-to-host.py

Transforms the output of `terraform output -json` into a Ansible hosts.yml used by cp-ansible.

```
usage: convert-to-host.py [-h] [--template TEMPLATE] input keypair

Reads a JSON output from terraform and converts it into an Ansible inventory/

positional arguments:
  input                JSON input file to read
  keypair              Name of the key pair to use for AWS instances

optional arguments:
  -h, --help           show this help message and exit
  --template TEMPLATE  Inventory template (default = hosts.j2)
```

Sample usage: `python3 convert-to-host.py my.json my_keypair --template hosts-kerberos.j2`

## stx_instances.py

Starts and stops ec2 instances in a proper order. Uses information from a terraform state file. Expects AWS credentials in default profile or environment

```
usage: stx-instances.py [-h] [--wait-time WAIT_TIME] [--dry-run] [--no-dry-run] [--state-file STATE_FILE] operation

Start or stop a set of EC2 instances in the appropriate order for a Kafka Cluster

positional arguments:
  operation             Start or stop instances

optional arguments:
  -h, --help            show this help message and exit
  --wait-time WAIT_TIME
                        Duration to wait in seconds between sets of machines when starting/stopping
  --dry-run             Perform a dry run. Default setting
  --no-dry-run          Don't perform a dry run
  --state-file STATE_FILE
                        The location of your terraform state file in which the instances are described
```

Sample usage: `python3 stx-instances.py start --no-dry-run`