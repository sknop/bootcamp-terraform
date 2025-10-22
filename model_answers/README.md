# Model Answers

I encourage you to try to solve the challenges in the labs yourself first 
before taking a sneak peak at the model answers posted here. 

You will learn a lot more from challenging yourself, digging through the documentation,
making mistakes and debugging these issues rather than simply copying the model answers from here.

Having said this, here is list of some model answers and their special features.

## rbac_zookeeper

ZooKeeper-based implementation of the full stack with

- SSL enabled
- mTLS listener
- Kerberos listener
- SASL/PLAIN listener with LDAP as the backend
- RBAC via LDAP

## rbac_kraft

As the ZooKeeper version, but with a KRaft quorum.

The connection from the brokers to the controller is secured using Kerberos.

## oidc_kraft

This is model answer for a cluster secured via OIDC with a Kraft controller. 

# Additional hints

Watch out for **region** and **domain** in the model answers.

If your domain defined in bootcamp-vpc is bootcamp.confluent.io (without a region),
then you will need to adjust the model answer to remove all hints of region.

The standard pattern in the answers for the domain is bootcamp-{{region}}.confluent.io
