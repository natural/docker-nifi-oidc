# docker-nifi-oidc

These docker images and scripts are used to create a local environment for the development
and test of NiFi OIDC functionality.

This repo was originally based on
[docker-test-mozilla-django-oidc](https://github.com/mozilla/docker-test-mozilla-django-oidc).  Refer to
[the README.md](https://github.com/mozilla/docker-test-mozilla-django-oidc/blob/master/README.md) in that repo
for more.


## Configuration Summary

### Names and Ports

`nifi.127.0.0.1.nip.io # Resolves to our NiFi node`
`oidc.127.0.0.1.nip.io # Resolves to our OIDC service`

`nifi.127.0.0.1.nip.io:8443 # NiFi Web UI HTTPS`
`oidc.127.0.0.1.nip.io:9443 # OIDC Web UI HTTPS`
`oidc.127.0.0.1.nip.io:8888 # OIDC Web UI HTTP`


### `nifi.properties`

nifi.security.keystore=./conf/keystore.jks
nifi.security.keystoreType=jks
nifi.security.keystorePasswd=xPmBPKqmoEg4y/nH3hKbGecMrw03KiI3gJhxlaPfpRk
nifi.security.keyPasswd=xPmBPKqmoEg4y/nH3hKbGecMrw03KiI3gJhxlaPfpRk
nifi.security.truststore=./conf/truststore.jks
nifi.security.truststoreType=jks
nifi.security.truststorePasswd=Ryz8DfwhIP0z4xZDyBo9wCmGKMejwk4J+DhMiEzyCm8

nifi.security.user.oidc.discovery.url=https://oidc.127.0.0.1.nip.io:9443/openid/.well-known/openid-configuration
nifi.security.user.oidc.client.id=779980
nifi.security.user.oidc.client.secret=31147e6a2a63440d2cca5e2c042d9662b3db1792d386cacb71ac6581
nifi.security.user.oidc.preferred.jwsalgorithm=HS256
nifi.security.user.oidc.additional.scopes=profile
nifi.security.user.oidc.claim.identifying.user=
nifi.security.user.oidc.tls.client.auth=NONE
nifi.security.user.oidc.tls.protocol=

### `authorizers.xml`

### OIDC



## Setup

### NiFi Setup Overview

* [Install NiFi](https://nifi.apache.org/docs/nifi-docs/html/getting-started.html#downloading-and-installing-nifi) from [source](https://gitbox.apache.org/repos/asf?p=nifi.git) or a [binary release](https://nifi.apache.org/download.html)
* [Instalfl NiFi Toolkit](https://nifi.apache.org/docs/nifi-docs/html/toolkit-guide.html) from [source](https://gitbox.apache.org/repos/asf?p=nifi.git) or a [binary release](https://nifi.apache.org/download.html)
* Use the toolkit to generate a keystore and truststore
* Configure NiFi for HTTPS

### NiFi Setup Instructions

Toolkit usage:

`$ cd nifi-toolkit-1.11.1`
`$ bin/tls-toolkit.sh standalone -n 'nifi.127.0.0.1.nip.io' -C 'CN=<yourname>, OU=NIFI' -O -o <yourdirectory> -d 300`




### OIDC Provider Setup Overview

* Clone this repo
* Start the docker services
* Configure the OIDC Provider for the NiFi Client

### OIDC Provder Setup Instructions


Generate certs, start services:

`$ cd proxy`
`$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ``pwd``/ssl-certs/oidc.127.0.0.1.nip.io.key -out ``pwd``/ssl-certs/oidc.127.0.0.1.nip.io.crt -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName='DNS:oidc.127.0.0.1.nip.io'"))`
`$ docker-compose up`
