# docker-nifi-oidc

These docker images and scripts are used to create a local environment for the development
and test of NiFi OIDC functionality and behavior.

This repo is a fork of
[docker-test-mozilla-django-oidc](https://github.com/mozilla/docker-test-mozilla-django-oidc) but now
bears little resemblance.

## Summary

###### NiFi Node
`nifi.127.0.0.1.nip.io`

###### NiFi Web UI
[https://nifi.127.0.0.1.nip.io:8443/nifi](https://nifi.127.0.0.1.nip.io:8443/nifi)

######  OIDC Provider
`oidc.127.0.0.1.nip.io`

######  OIDC Test Service Web UI
[https://oidc.127.0.0.1.nip.io:9443/](https://oidc.127.0.0.1.nip.io:9443)

User account credentials:  `tester/password`

###### OIDC Test Service Admin UI
[https://oidc.127.0.0.1.nip.io:9443/admin](https://oidc.127.0.0.1.nip.io:9443/admin)

Staff account credentials:  `admin/password`

#### NiFi Properties

These values will change infrequently during development and testing:

```properties
nifi.security.user.authorizer=file-provider
nifi.security.user.oidc.discovery.url=https://oidc.127.0.0.1.nip.io:9443/openid/.well-known/openid-configuration
```

These values will change often:

```properties
nifi.security.user.oidc.client.id=779980
nifi.security.user.oidc.client.secret=31147e6a2a63440d2cca5e2c042d9662b3db1792d386cacb71ac6581
nifi.security.user.oidc.preferred.jwsalgorithm=HS256
nifi.security.user.oidc.additional.scopes=profile
nifi.security.user.oidc.claim.identifying.user=
nifi.security.user.oidc.tls.client.auth=NONE
nifi.security.user.oidc.tls.protocol=
```


## Installation and Setup

This setup contains a single NiFi instance running on the host, not in a container.  Initial setup is minimal
and includes TLS certificates and keys for NiFi and the OIDC provider.

Make a space for the installation:

```shell script
$ mkdir nifi-test
$ cd nifi-test
```

Then define the environment:

```shell script
$ export NIFI_HOST=nifi.127.0.0.1.nip.io
$ export OIDC_HOST=oidc.127.0.0.1.nip.io

$ export NIFI_BUILD=nifi-1.12.0-SNAPSHOT
$ export TOOLKIT_BUILD=nifi-toolkit-1.11.1

$ export SERVICE_FILES=docker-nifi-oidc/services/
```

Clone this repo and build the images:

```shell script
$ git clone git@github.com:natural/docker-nifi-oidc.git
$ cd docker-nifi-oidc; make build; cd -
```


Install [the NiFi Toolkit](https://nifi.apache.org/docs/nifi-docs/html/toolkit-guide.html) from [source](https://gitbox.apache.org/repos/asf?p=nifi.git) or a [binary release](https://nifi.apache.org/download.html).
Then use the toolkit to generate a keystore and truststore for the NiFi node:

```shell script
$ unzip $TOOLKIT_BUILD-bin.zip
$ $TOOLKIT_BUILD/bin/tls-toolkit.sh standalone -n $NIFI_HOST -C 'CN=admin, OU=NIFI' -O -o ./ssl-nifi -d 90
$ sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ssl-nifi/nifi-cert.pem
```

[Install NiFi](https://nifi.apache.org/docs/nifi-docs/html/getting-started.html#downloading-and-installing-nifi) from [source](https://gitbox.apache.org/repos/asf?p=nifi.git) or a [binary release](https://nifi.apache.org/download.html) and
copy the keystore and truststore files:

```shell script
$ unzip $NIFI_BUILD-bin.zip
$ cp ssl-nifi/$NIFI_HOST/* $NIFI_BUILD/conf/
```

Modify or install the example `authorizers.xml` before continuing:

```shell script
$ cp docker-nifi-oidc/conf/authorizers.xml $NIFI_BUILD/conf/
```


Create a self-signed certificate for the OIDC server:

```shell script
$ mkdir ssl-oidc
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout `pwd`/ssl-oidc/$OIDC_HOST.key \
     -out `pwd`/ssl-oidc/$OIDC_HOST.crt \
     -subj "/C=US/ST=NY/L=NY/OU=NIFI/CN=$OIDC_HOST" \
     -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName='DNS:$OIDC_HOST'"))
```

The NiFi node trust store gets the OIDC host certificate by an import:

```shell script
$ keytool -importcert -file ./ssl-oidc/$OIDC_HOST.crt \
    -keystore ./$NIFI_BUILD/conf/truststore.jks \
    -storepass `grep truststorePasswd ./ssl-nifi/$NIFI_HOST/nifi.properties|cut -f 2 -d "="`
```

Start the OIDC and proxy services:

```shell script
$ docker-compose -f $SERVICE_FILES/https-nifi.yaml up
```

Alternatively, for Nginx HTTPS proxy to both OIDC HTTP and NiFi HTTP:

```shell script
$ docker-compose -f $SERVICE_FILES/proxy-nifi.yaml up
```


### Cleanup

Stop docker services:

```shell script
$ docker-compose -f $SERVICE_FILES/https-nifi.yaml down
```

Remove docker containers:

```shell script
$ docker image rm nifi-oidc-test-provider
```

Stop NiFi node and remove the installation:

```shell script
$ $NIFI_BUILD/bin/nifi.sh stop
$ rm -rf $NIFI_BUILD
```

Remove SSL certificates:

```shell script
$ sudo security delete-certificate -Z `security find-certificate -a -Z -c "localhost"|head -n 1|cut -f 3 -d " "`
```
