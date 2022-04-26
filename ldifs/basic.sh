#!/bin/sh 

ldapadd -H ldaps://samba.bootcamp-partners.confluent.io -D Administrator@BOOTCAMP-PARTNERS.CONFLUENT.IO  -w Bootcamp4Ever -f kafka.ldif
ldapadd -H ldaps://samba.bootcamp-partners.confluent.io -D Administrator@BOOTCAMP-PARTNERS.CONFLUENT.IO  -w Bootcamp4Ever -f ou.ldif
