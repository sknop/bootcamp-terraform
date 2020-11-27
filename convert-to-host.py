from __future__ import print_function

from jinja2 import Template
import json
import sys
import pprint

OUTPUT_KEYS = {
    'kafka_broker' : 'broker_private_dns',
    'kafka_connect' : 'connect_private_dns',
    'schema_registry' : 'schema_private_dns',
    'control_center' : 'control_center_private_dns',
    'ksql' : 'ksql_private_dns',
    'kafka_rest' : 'rest_private_dns',
    'zookeeper' : 'zookeeper_private_dns'
}

CLUSTER_DATA = 'cluster_data'


class TerraformResults:
    def __init__(self, fname, uname, tempFile):
        self.filename = fname
        self.username = uname
        self.template = self.create_template(tempFile)

        self.json_output = self.parse_json()
        self.all_ips = []
        self.ip_dict = {}

        self.filter_json()

    def create_template(self, tempFile):
        with open(tempFile) as f:
            temp = f.read()

        return Template(temp)

    def parse_json(self):
        with open(self.filename) as f:
            content = f.read()

        output = json.loads(content)
        return output

    def filter_json(self):
        for key,name in OUTPUT_KEYS.items():
            ip = self.filter_item(name)[0]
            self.all_ips += ip
            self.ip_dict[key] = ip

        self.ip_dict[CLUSTER_DATA] = self.json_output[CLUSTER_DATA]['value']

    def filter_item(self, name):
        return self.json_output[name]['value']

    def output(self):
        pp = pprint.PrettyPrinter(indent=4)

        print('All IPs:')
        pp.pprint(self.all_ips)

        print()

        print('Broken into sections:')
        pp.pprint(self.ip_dict)

        self.print_ip()
        self.print_hosts()

    def print_ip(self):
        with open(self.username + '.txt', 'w+') as f:
            f.writelines('\n'.join(self.all_ips))
            print(file=f)

    def print_hosts(self):
        fname = 'hosts.yml'
        with open(fname, "w+") as f:
            print(self.template.render(self.ip_dict),file=f)


if __name__ == '__main__':
    filename = sys.argv[1]
    username = sys.argv[2]
    template = sys.argv[3]

    results = TerraformResults(filename, username, template)
    results.output()
