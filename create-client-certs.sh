#!/bin/bash

if [ "$#" -eq 3 ]
then
	sambahost=$1
	source=$2
	target=$3

	curl -H "Content-Type: application/json" --request POST --data @$source  http://${sambahost}:8000/clients -o $target
else
	echo "Usage $0 <sambahost> <source.json> <target.zip>"
	exit 1
fi
