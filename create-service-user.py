from ldap3 import Connection
import pexpect
from pprint import pprint
import sys
import configparser
import logging

# input: 
#   configuration file (LDAPS URL, username, password, REALM, password)
#   file containing list of 
#       <principal>, <hostname>

class ServiceUser :
    pass

class Generator:
    def __init__(self, configFile, hostFile, owner):
        self.configFile = configFile
        self.hostFile = hostFile
        self.owner = owner
        
        self.initLogging()
        self.initialise()
        self.connectLDAP()

        self.processHostFile()

        self.disconnectLDAP()

    def initialise(self):
        parser = configparser.ConfigParser()
        with open(self.configFile) as f:
            lines = '[top]\n' + f.read() # hack, do not want [top] in config file, so add it here
            parser.read_string(lines)

        # we expect certain entries in the config file, or we will bail. There are no defaults

        parser = parser['top']
        self.setConfig('ldaps_url', parser)
        self.setConfig('username', parser)
        self.setConfig('password', parser)
        self.setConfig('realm', parser)
        self.setConfig('service_password', parser)
        self.setConfig('base_dn', parser)


    def initLogging(self):
        self.logger = logging.getLogger('create-service-user')
        self.logger.setLevel(logging.DEBUG) # change to INFO or DEBUG for more output

        handler = logging.StreamHandler()
        handler.setLevel(logging.INFO)

        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)

        self.logger.addHandler(handler)

    def setConfig(self, key, parser):
        if key not in parser:
            self.logger.error(f"Cannot find {key} in config file. Aborting")
            sys.exit(2)
        self.__setattr__(key, parser[key])
        self.logger.info(f"{key} : {parser[key]}")

    def connectLDAP(self):
        self.ldap = Connection(self.ldaps_url, user=self.username, password=self.password, auto_bind=True)
        self.logger.info(self.ldap)

    def processHostFile(self):
        with open(self.hostFile) as f:
            content = f.read()
        
        # split into lines
        lines = content.split("\n")
        for line in lines:
            if line != "":
                entries = line.split(",")
                principal = entries[0]
                host = entries[1]

                print(f"{principal} --> {host}")
                (service_name, filename) = self.createServiceUser(principal, host)

                self.create_keytab(service_name, filename)
        
    def createServiceUser(self, principal, host):
        short_host = host.split('.')[0]
        cn = f"{principal} {short_host}"
        dn = f"CN={cn},{self.base_dn}"
        service_name = f"{principal}/{host}"
        user_principal_name = f"{service_name}@{self.realm}"

        user_attrs = {}
        user_attrs['objectClass'] = ['top', 'person', 'organizationalPerson', 'user']
        user_attrs['cn'] = cn
        user_attrs['accountExpires'] = '0'
        user_attrs['userPrincipalName'] = user_principal_name
        user_attrs['servicePrincipalName'] = service_name

        self.logger.info(user_attrs)

        self.ldap.add(dn, attributes = user_attrs)
        self.logger.info(self.ldap.result)

        # set the password

        self.ldap.extend.microsoft.modify_password(dn, self.service_password)
        self.logger.info(self.ldap.result)

        # set the account active and password non-expiring

        self.ldap.modify(dn, {"userAccountControl" : [('MODIFY_REPLACE', 66048)]})
        self.logger.info(self.ldap.result)
    
        filename = f"{principal}-{short_host}.keytab"

        return (service_name,filename)

    def create_keytab(self, service_name, filename):
        # expects ktutil to be installed in the path
        encryptions = [ "aes256-cts", "aes128-cts" ]

        for encryption in encryptions:
            prompt = "ktutil:  "
            cmd = f"addent -password -p {service_name} -k 1 -e {encryption}"

            child = pexpect.spawn("ktutil")
            child.expect(prompt)
            child.sendline(cmd)
            child.expect("Password for .*:")
            child.sendline(self.service_password)
            child.expect(prompt)
            child.sendline(f"write_kt {filename}")
            child.expect(prompt)
            child.sendline("q")

    def disconnectLDAP(self):
        self.ldap.unbind()

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: " + sys.argv[0] + " <config-file> <host-file> <owner>", file=sys.stderr)
        sys.exit(1)

    configFile = sys.argv[1]
    hostFile = sys.argv[2]
    owner = sys.argv[3]

    generator = Generator(configFile, hostFile, owner)


