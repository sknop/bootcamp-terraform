import argparse
import json

from jinja2 import Template

OUTPUT_KEYS = {
    "kafka_broker": ["broker_private_dns", "broker_alternate_dns"],
    "kafka_connect": ["connect_private_dns", "connect_alternate_dns"],
    "schema_registry": ["schema_private_dns", "schema_alternate_dns" ],
    "control_center": ["control_center_private_dns", "control_center_alternate_dns"],
    "ksql": ["ksql_private_dns", "ksql_alternate_dns"],
    "kafka_rest": ["rest_private_dns", "rest_alternate_dns"],
    "zookeeper": ["zookeeper_private_dns", "zookeeper_alternate_dns"]
}

KERBEROS_PRINCIPALS = {
    "kafka_broker": "kafka",
    "kafka_connect": "kafka-connect",
    "schema_registry": "schema-registry",
    "control_center": "control-center",
    "ksql": "ksqldb",
    "kafka_rest": "kafka_rest",
    "zookeeper": "zookeeper",
}

CLUSTER_DATA = "cluster_data"


def create_template(temp_file):
    with open(temp_file) as f:
        temp = f.read()

    return Template(temp)


class TerraformResults:
    def __init__(self, fname, uname, tempFile):
        self.filename = fname
        self.username = uname
        self.tempFile = tempFile
        self.template = create_template(tempFile)

        self.json_output = self.parse_json()
        self.all_ips = []
        self.ip_dict = {}
        self.host_dict = {}
        self.kerberos_dict = {}

        self.filter_json()

    def parse_json(self):
        with open(self.filename) as f:
            content = f.read()

        output = json.loads(content)
        return output

    def create_kerberos_dict(self):
        for key, name in KERBEROS_PRINCIPALS.items():
            ip_list = self.ip_dict[key]
            self.kerberos_dict[name] = ip_list

    def filter_json(self):
        for key, name in OUTPUT_KEYS.items():
            ip = self.filter_item(name[0])
            alt = self.filter_item(name[1])

            self.all_ips += ip

            if alt:
                self.ip_dict[key] = (ip, alt)
            else:
                self.ip_dict[key] = ip

            self.host_dict[key] = ip

        self.create_kerberos_dict()

        self.ip_dict[CLUSTER_DATA] = self.json_output[CLUSTER_DATA]["value"]
        self.host_dict[CLUSTER_DATA] = self.json_output[CLUSTER_DATA]["value"]

    def filter_item(self, name):
        if name in self.json_output:
            return self.json_output[name]["value"][0]
        else:
            return None

    def output(self):
        self.print_hosts()
        self.print_json()
        print(f"Generated JSON file for certificates: {self.username}.json")

    def print_ip(self):
        with open(self.username + ".txt", "w+") as f:
            f.writelines("\n".join(self.all_ips))
            print(file=f)

    def print_json(self):
        data = {
            KERBEROS_PRINCIPALS[x]: y
            for (x, y) in self.ip_dict.items()
            if x not in "cluster_data"
        }
        with open(self.username + ".json", "w+") as f:
            json.dump(data, f, indent=4)

    def print_hosts(self):
        host_filename = self.tempFile.replace(".j2", ".yml")
        with open(host_filename, "w+") as f:
            print(self.template.render(self.host_dict), file=f)

    def print_kerberos(self):
        print("Kerberos list:\n")
        with open(self.username + ".csv", "w+") as f:
            for key, ip_list in self.kerberos_dict.items():
                for ip in ip_list:
                    print(f"{key},{ip}")
                    print(f"{key},{ip}", file=f)


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Reads a JSON output from terraform and converts it into an Ansible inventory/"
    )

    parser.add_argument("input", help="JSON input file to read")
    parser.add_argument("username", help="Name of the user for the output files")
    parser.add_argument(
        "--template",
        help="Inventory template (default = hosts.j2)",
        default="./hosts.j2",
    )

    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arguments()
    results = TerraformResults(args.input, args.username, args.template)
    results.output()
