#!/usr/bin/env bash

function generate_one_client {
	common_name=$1

	vault write -field certificate kafka-int-ca/issue/kafka-client common_name=${common_name} format=pem_bundle > $common_name.pem

	openssl pkcs12 -inkey ${common_name}.pem -in ${common_name}.pem -name ${common_name} -export -out ${common_name}.p12 -password pass:changeme

	keytool -importkeystore -srcstorepass changeme -deststorepass changeme -destkeystore ${common_name}-keystore.jks -srckeystore ${common_name}.p12 -srcstoretype PKCS12
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <client file> <zip file>"
    exit 1
fi

export VAULT_TOKEN=`vault token create -role kafka-client -format table | grep token | grep -v token_ | awk '{ print $2 }'`

input=$1
output=$2

while IFS= read -r line
do
	echo "$line"
	generate_one_client "$line"
done < $input

zip $output *.jks
rm *.pem *.p12 *.jks
