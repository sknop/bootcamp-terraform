#!/usr/bin/env bash

function generate_one_client {
	common_name=$1

	vault write -field certificate kafka-int-ca/issue/kafka-client common_name=${common_name} format=pem_bundle > ${output_dir}/$common_name.pem

	openssl pkcs12 -inkey ${output_dir}/${common_name}.pem -in ${output_dir}/${common_name}.pem -name ${common_name} -export -out ${output_dir}/${common_name}.p12 -password pass:changeme

	keytool -importkeystore -srcstorepass changeme -deststorepass changeme -destkeystore ${output_dir}/${common_name}-keystore.jks -srckeystore ${output_dir}/${common_name}.p12 -srcstoretype PKCS12
}

function generate_one_keystore {
	host=$1
	# common_name=kafka.bootcamp-europe.internal
	common_name=$1

	vault write -field certificate kafka-int-ca/issue/kafka-server common_name=${common_name} alt_names=$host format=pem_bundle > ${output_dir}/$host.pem

	openssl pkcs12 -inkey ${output_dir}/${host}.pem -in ${output_dir}/${host}.pem -name ${host} -export -out ${output_dir}/${host}.p12 -password pass:changeme

	keytool -importkeystore -srcstorepass changeme -deststorepass changeme -destkeystore ${output_dir}/${host}-keystore.jks -srckeystore ${output_dir}/${host}.p12 -srcstoretype PKCS12
}

function print_usage {
	echo "*** Error: $1 ***"
	echo "Usage: ${prog_name} <cert_type> <input_file>"
	echo "	<cert_type> -> {client|server}"
	echo "	<input_file> -> text file with list of fqdns that needs certs"
	exit 1
}

[ $# -ne 2 ] && print_usage "Need 2 arguments"

prog_name=$0
cert_type=$1
input=$2

[ "${cert_type}" != "client" ] && [ "${cert_type}" != "server" ] && print_usage "Invalid cert type"

if [ "${cert_type}" = "client" ]
then
	export VAULT_TOKEN=`vault token create -role kafka-client -format table | grep token | grep -v token_ | awk '{ print $2 }'`
else
	export VAULT_TOKEN=`vault token create -role kafka-server -format table | grep token | grep -v token_ | awk '{ print $2 }'`
fi

[ ! -f ${input} ] && print_usage "${input} file does not exist"

baseinput=`basename ${input}`
output_dir_part=${baseinput}.${cert_type}
output_dir=~/data/${output_dir_part}
zip_file=${output_dir}.zip

bak_dir=~/data/bak
mkdir -p ${bak_dir}

[ -d ${output_dir} ] && rm -Rf ${output_dir}
mkdir -p ${output_dir}

[ -f ${zip_file} ] && rm -f ${zip_file}

echo "Generating ${cert_type} cert for entries in ${input} ..."
while IFS= read -r line
do
	echo "$line"
	if [ "${cert_type}" = "client" ]
	then
		echo generate_one_client "$line"
		# generate_one_client "$line"
	else
		echo generate_one_keystore "$line"
		# generate_one_keystore "$line"
	fi
done < $input
cd `dirname ${output_dir}`
zip -r ${zip_file} ${output_dir_part}
cd -

echo "${zip_file} has generated certs"
