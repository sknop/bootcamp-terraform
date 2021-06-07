#!/bin/bash 

source=$1
target=$2

curl -H "Content-Type: application/json" --request POST --data @$source  http://ip-172-30-18-36.eu-west-1.compute.internal:8000/generate -o $target
