import json
from time import sleep
import boto3
import argparse
from botocore.exceptions import ClientError

CONTROL_CENTER_NAME='control-center'
SCHEMA_REGISTRY_NAME='schema'
KAFKA_CONNECT_NAME='connect-cluster'
REST_API_NAME='rest'
KSQLDB_NAME='ksql'
BROKER_NAME='brokers'
ZOOKEEPER_NAME='zookeepers'


def stx_instances(operation, instance_ids: list, dry_run: bool, wait_time: int, ec2_client):
    if not instance_ids:
        print("No instances provided, skipping")
        return
    
    if operation == 'start':
        try:
            print(f'Starting  {len(instance_ids)} instances\n')
            response = ec2_client.start_instances(
                InstanceIds=instance_ids,
                DryRun=dry_run
            )

            print(response)
        except ClientError as e:
            if e.response['Error']['Code']  != "DryRunOperation":
                raise e
            print("All good but dry run")
    elif operation == 'stop':
        try:
            print(f'Stopping {len(instance_ids)} instances\n')
            response = ec2_client.stop_instances(
                InstanceIds=instance_ids,
                DryRun=dry_run
            )

            print(response)
        except ClientError as e:
            if e.response['Error']['Code']  != "DryRunOperation":
                raise e
            print("All good but dry run\n")

def filter_instances_ids(state: dict, instance_name: str):

    instance_ids = list()
    print(f'\nFinding instance ids for {instance_name}\n')
    for r in filter(lambda x: x.get("name") == instance_name and x.get("type") == "aws_instance", state["resources"]):
        for i in r["instances"]:
            instance_ids.append(i["attributes"]["arn"].split('/')[-1])
    return instance_ids




def main(operation, wait_time, dry_run, state_file):

    ec2 = boto3.client('ec2')
    with open(state_file) as f:
        state = json.loads(f.read())

    stop_order = [
        CONTROL_CENTER_NAME,
        SCHEMA_REGISTRY_NAME,
        KAFKA_CONNECT_NAME,
        REST_API_NAME,
        KSQLDB_NAME,
        BROKER_NAME,
        ZOOKEEPER_NAME
        ]

    if operation == 'start':
        order = reversed(stop_order)
    elif operation == 'stop':
        order =stop_order
    else:
        raise Exception('uh oh')

    for handle in order:
        instance_ids = filter_instances_ids(state=state, instance_name=handle)
        stx_instances(operation,instance_ids,dry_run,wait_time,ec2)
        for x in range(wait_time):
            print(f'Waiting {wait_time-x} more seconds for instances to {operation}')
            sleep(1)



def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Start or stop a set of EC2 instances in the appropriate order for a Kafka Cluster"
    )

    parser.add_argument("operation", help="Start or stop instances")
    parser.add_argument("--wait-time", help="Duration to wait in seconds between sets of machines when starting/stopping", default=60)
    parser.add_argument('--dry-run', action='store_true', help="Perform a dry run. Default setting")
    parser.add_argument('--no-dry-run', dest='dry_run', action='store_false', help="Don't perform a dry run")
    parser.set_defaults(dry_run=True)
    parser.add_argument("--state-file",help="The location of your terraform state file in which the instances are described", default="./terraform.tfstate" )

    return parser.parse_args()
    
            
    
if __name__ == '__main__':
    args = parse_arguments()
    main(
        operation=args.operation,
        wait_time=int(args.wait_time),
        dry_run=args.dry_run,
        state_file=args.state_file
        )