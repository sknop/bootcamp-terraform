from ldap3 import Connection
import pexpect
import zipfile
from pprint import pprint
import sys
import configparser
from pathlib import Path
import json
import logging


# input:
#   configuration file (LDAPS URL, username, password, REALM, password)
#   file containing list of 
#       <principal>, <hostname>


class ServiceUser:
    pass


class Generator:
    def __init__(self, config_file, host_file, owner_name):
        self.logger = logging.getLogger('create-service-user')
        self.configFile = config_file
        self.hostFile = host_file
        self.owner = owner_name

        self.init_logging()
        self.initialise()
        self.ldap = self.connect_ldap()

        self.hosts = self.load_host_file()
        self.process_host_file()

        self.disconnect_ldap()

    def initialise(self):
        parser = configparser.ConfigParser()
        with open(self.configFile) as f:
            lines = '[top]\n' + f.read()  # hack, do not want [top] in config file, so add it here
            parser.read_string(lines)

        # we expect certain entries in the config file, or we will bail. There are no defaults

        parser = parser['top']
        self.set_config('ldaps_url', parser)
        self.set_config('username', parser)
        self.set_config('password', parser)
        self.set_config('realm', parser)
        self.set_config('service_password', parser)
        self.set_config('base_dn', parser)

    def init_logging(self):
        self.logger.setLevel(logging.DEBUG)  # change to INFO or DEBUG for more output

        handler = logging.StreamHandler()
        handler.setLevel(logging.INFO)

        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)

        self.logger.addHandler(handler)

    def set_config(self, key, parser):
        if key not in parser:
            self.logger.error(f"Cannot find {key} in config file. Aborting")
            sys.exit(2)
        self.__setattr__(key, parser[key])
        self.logger.info(f"{key} : {parser[key]}")

    def connect_ldap(self):
        ldap = Connection(self.ldaps_url, user=self.username, password=self.password, auto_bind=True)
        self.logger.info(ldap)

        return ldap

    def archive_and_delete_files(self, files):
        with zipfile.ZipFile(f"{self.owner}.zip", "w") as archive:
            for f in files:
                archive.write(f)

        for f in files:
            p = Path(f)
            p.unlink()

    def load_host_file(self):
        with open(self.hostFile) as f:
            content = f.read()

        return json.loads(content)

    def process_host_file(self):
        files = []

        for principal, hosts in self.hosts.items():
            for host in hosts:
                print(f"{principal} --> {host}")
                (service_name, filename) = self.create_service_user(principal, host)

                self.create_keytab(service_name, filename)
                files.append(filename)

        self.archive_and_delete_files(files)

    def create_service_user(self, principal, host):
        short_host = host.split('.')[0]
        cn = f"{principal} {short_host}"
        dn = f"CN={cn},{self.base_dn}"
        service_name = f"{principal}/{host}"
        user_principal_name = f"{service_name}@{self.realm}"

        user_attrs = {
            'objectClass': ['top', 'person', 'organizationalPerson', 'user'],
            'cn': cn,
            'accountExpires': '0',
            'userPrincipalName': user_principal_name,
            'servicePrincipalName': service_name
        }

        self.logger.info(user_attrs)

        self.ldap.add(dn, attributes=user_attrs)
        self.logger.info(self.ldap.result)

        # set the password

        self.ldap.extend.microsoft.modify_password(dn, self.service_password)
        self.logger.info(self.ldap.result)

        # set the account active and password non-expiring

        self.ldap.modify(dn, {"userAccountControl": [('MODIFY_REPLACE', 66048)]})
        self.logger.info(self.ldap.result)

        filename = f"{principal}-{short_host}.keytab"

        return service_name, filename

    def create_keytab(self, service_name, filename):
        # expects ktutil to be installed in the path
        encryptions = ["aes256-cts", "aes128-cts", "rc4-hmac"]

        prompt = "ktutil:  "

        child = pexpect.spawn("ktutil")

        for encryption in encryptions:
            cmd = f"addent -password -p {service_name} -k 1 -e {encryption}"
            child.expect(prompt)
            child.sendline(cmd)
            child.expect("Password for .*:")
            child.sendline(self.service_password)

        child.expect(prompt)
        child.sendline(f"write_kt {filename}")

        child.expect(prompt)
        child.sendline("q")

    def disconnect_ldap(self):
        self.ldap.unbind()


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: " + sys.argv[0] + " <config-file> <host-file> <owner>", file=sys.stderr)
        sys.exit(1)

    configFile = sys.argv[1]
    hostFile = sys.argv[2]
    owner = sys.argv[3]

    generator = Generator(configFile, hostFile, owner)
