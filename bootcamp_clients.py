import os
from ldap3 import Connection
import pexpect
import zipfile
import subprocess
import sys
import shutil
import configparser
from pathlib import Path, PurePath
import json
import logging

# input:
#   configuration file (LDAPS URL, username, password, REALM, password)
#   file containing list of 
#       <principal>, <hostname>


KERBEROS_DIRECTORY = "kerberos"
SSL_DIRECTORY = "ssl"


class Generator:
    def __init__(self, base_dir, config_file, host_entries, owner_name):
        self.logger = logging.getLogger('bootcamp')
        self.base_dir = base_dir
        self.config_file = config_file
        self.hosts = host_entries
        self.owner = owner_name
        self.directories = [KERBEROS_DIRECTORY, SSL_DIRECTORY]
        self.zip_file_name = f"{self.owner}.zip"

        self.init_logging()
        self.initialise()
        self.ldap = self.connect_ldap()

        # self.logger.info(f"Current Directory: {os.getcwd()}")

        self.ensure_directories()

        self.process_host_file()

        self.disconnect_ldap()

        self.destroy_directories()
        
    def initialise(self):
        parser = configparser.ConfigParser()
        with open(self.config_file) as f:
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
        self.set_config('truststore_file', parser)

    def init_logging(self):
        self.logger.setLevel(logging.INFO)  # change to INFO or DEBUG for more output

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
        with zipfile.ZipFile(self.zip_file_name, "w") as archive:
            for f in files:
                archive.write(f)

        for f in files:
            p = Path(f)
            p.unlink()

    def process_host_file(self):
        files = []

        for principal, hosts in self.hosts.items():
            for host in hosts:
                print(f"{principal} --> {host}")
                (service_name, filename) = self.create_service_user(self.directories[0], principal, host)

                self.create_keytab(service_name, filename)
                files.append(filename)

                filename = self.create_certificate(self.directories[1], principal, host)
                files.append(filename)

        filename = self.copy_truststore(self.directories[1], self.truststore_file)
        if filename:
            files.append(filename)

        self.archive_and_delete_files(files)

    def create_service_user(self, basedir, principal, host):
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

        filename = os.path.join(basedir, f"{principal}-{short_host}.keytab")

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

    def create_certificate(self, basedir, principal, host):
        # expect vault, openssl and keytool to be installed in the path
        filename = os.path.join(basedir, f"{host}-keystore.jks")
        pem_filename = os.path.join(basedir, f"{host}.pem")
        p12_filename = os.path.join(basedir, f"{host}.p12")

        self.logger.info(f"Creating certificate with {pem_filename} {p12_filename} {filename}")

        command = f"vault write -field certificate kafka-int-ca/issue/kafka-server "\
                  f"common_name=kafka.servers.kafka.bootcamp.confluent.io alt_names={host} format=pem_bundle".split()
        with open(pem_filename, 'w') as f:
            process = subprocess.Popen(command, stdout=f, stderr=subprocess.PIPE)
            stdout, stderr = process.communicate()
            self.logger.info(stderr.decode('utf-8'))

        command = f"openssl pkcs12 -inkey {pem_filename} -in {pem_filename} "\
                  f"-name {host} -export -out {p12_filename} -password pass:changeme".split()
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        self.logger.info(stderr.decode('utf-8'))

        command = f"keytool -importkeystore -srcstorepass changeme -deststorepass changeme -destkeystore "\
                  f"{filename} -srckeystore {p12_filename} -srcstoretype PKCS12".split()
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        self.logger.info(stderr.decode('utf-8'))

        # remove intermediates
        os.unlink(pem_filename)
        os.unlink(p12_filename)

        return filename

    def copy_truststore(self, target_dir, truststore_filename):
        # check file exists in source
        # if exists
        #   take basename
        #   create targetname
        #   copy source to target
        # return targetname
        target_name = None
        source_path = Path(truststore_filename)
        if source_path.is_file():
            basename = PurePath(source_path.absolute()).name
            target_path = PurePath(target_dir, basename)
            shutil.copyfile(source_path.absolute(), target_path)
            target_name = target_path.as_posix()
        
        return target_name

    def disconnect_ldap(self):
        self.ldap.unbind()

    def ensure_directories(self):
        # keep everything relative to the base directory
        os.chdir(self.base_dir)

        for p in self.directories:
            os.makedirs(p, exist_ok=True)

    def destroy_directories(self):
        try:
            for p in self.directories:
                os.removedirs(p)
        except OSError as err:
            self.logger.error(f"Destroy Directory raised {err}")

        # os.chdir(self.cwd)


def load_host_file(filename):
    with open(filename) as f:
        content = f.read()

    return json.loads(content)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: " + sys.argv[0] + " <config-file> <host-file> <owner>", file=sys.stderr)
        sys.exit(1)

    config = sys.argv[1]
    host_file = sys.argv[2]
    owner = sys.argv[3]

    hosts = load_host_file(host_file)

    generator = Generator('.', config, hosts, owner)
    print(f"Created {generator.zip_file_name}")
