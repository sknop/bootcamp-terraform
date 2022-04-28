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


class ClientGenerator:
    def __init__(self, base_dir, config_file, host_entries, owner_name):
        self.logger = logging.getLogger('bootcamp_client')
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
        self.set_config('base_dn', parser)

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

        for principal, details in self.hosts.items():
            cn = details[0]
            password = details[1]

            print(f"{principal} --> {cn} {password}")
            (user_name, filename) = self.create_user(self.directories[0], principal, cn, password)

            self.create_keytab(user_name, password, filename)
            files.append(filename)

            # filename = self.create_certificate(self.directories[1], principal)
            # files.append(filename)

        self.archive_and_delete_files(files)

    def create_user(self, basedir, principal, cn, password):
        dn = f"CN={cn},{self.base_dn}"
        user_principal_name = f"{principal}@{self.realm}"
        sAMAccountName = principal

        user_attrs = {
            'objectClass': ['top', 'person', 'organizationalPerson', 'user'],
            'cn': cn,
            'accountExpires': '0',
            'userPrincipalName': user_principal_name,
            'sAMAccountName': sAMAccountName
        }

        self.logger.info(user_attrs)

        self.ldap.add(dn, attributes=user_attrs)
        self.logger.info(self.ldap.result)

        # set the password

        self.ldap.extend.microsoft.modify_password(dn, password)
        self.logger.info(self.ldap.result)

        # set the account active and password non-expiring

        self.ldap.modify(dn, {"userAccountControl": [('MODIFY_REPLACE', 66048)]})
        self.logger.info(self.ldap.result)

        filename = os.path.join(basedir, f"{principal}.keytab")

        return user_principal_name, filename

    def create_keytab(self, principal, password, filename):
        # expects ktutil to be installed in the path
        encryptions = ["aes256-cts", "aes128-cts"]

        prompt = "ktutil:  "

        child = pexpect.spawn("ktutil")

        for encryption in encryptions:
            cmd = f"addent -password -p {principal} -k 1 -e {encryption}"
            child.expect(prompt)
            child.sendline(cmd)
            child.expect("Password for .*:")
            child.sendline(password)

        child.expect(prompt)
        child.sendline(f"write_kt {filename}")

        child.expect(prompt)
        child.sendline("q")

    def create_certificate(self, basedir, principal):
        # expect vault, openssl and keytool to be installed in the path
        filename = os.path.join(basedir, f"{principal}-keystore.jks")
        pem_filename = os.path.join(basedir, f"{principal}.pem")
        p12_filename = os.path.join(basedir, f"{principal}.p12")

        self.logger.info(f"Creating certificate with {pem_filename} {p12_filename} {filename}")

        command = f"vault write -field certificate kafka-int-ca/issue/kafka-client " \
                  f"common_name={principal}.clients.kafka.bootcamp.confluent.io format=pem_bundle".split()
        with open(pem_filename, 'w') as f:
            process = subprocess.Popen(command, stdout=f, stderr=subprocess.PIPE)
            stdout, stderr = process.communicate()
            self.logger.info(stderr.decode('utf-8'))

        command = f"openssl pkcs12 -inkey {pem_filename} -in {pem_filename} " \
                  f"-name {principal} -export -out {p12_filename} -password pass:changeme".split()
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        self.logger.info(stderr.decode('utf-8'))

        command = f"keytool -importkeystore -srcstorepass changeme -deststorepass changeme -destkeystore " \
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


def load_users_file(filename):
    with open(filename) as f:
        content = f.read()

    return json.loads(content)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: " + sys.argv[0] + " <config-file> <user-file> <owner>", file=sys.stderr)
        sys.exit(1)

    config = sys.argv[1]
    user_file = sys.argv[2]
    owner = sys.argv[3]

    users = load_users_file(user_file)

    generator = ClientGenerator('.', config, users, owner)
    print(f"Created {generator.zip_file_name}")
