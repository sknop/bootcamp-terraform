# bootcamp-terraform

Confluent Bootcamp conform terraform scripts and configuration file.

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
