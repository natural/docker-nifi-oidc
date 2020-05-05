# docker-nifi-oidc

These docker images and scripts are used to create a local environment for the development
and test of NiFi OIDC functionality.  

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

###### OIDC Test Service Admin UI
[https://oidc.127.0.0.1.nip.io:9443/admin](https://oidc.127.0.0.1.nip.io:9443/admin)


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

To configure an HTTPS NiFi node, set properties like this:

```properties
nifi.security.keystore=./conf/keystore.jks
nifi.security.keystoreType=jks
nifi.security.keystorePasswd=xPmBPKqmoEg4y/nH3hKbGecMrw03KiI3gJhxlaPfpRk
nifi.security.keyPasswd=xPmBPKqmoEg4y/nH3hKbGecMrw03KiI3gJhxlaPfpRk
nifi.security.truststore=./conf/truststore.jks
nifi.security.truststoreType=jks
nifi.security.truststorePasswd=Ryz8DfwhIP0z4xZDyBo9wCmGKMejwk4J+DhMiEzyCm8

nifi.web.https.host=nifi.127.0.0.1.nip.io
nifi.web.https.port=8443
```

To configure an HTTP NiFi node, set properties like this:

```properties
nifi.security.keystore=
nifi.security.keystoreType=
nifi.security.keystorePasswd=
nifi.security.keyPasswd=
nifi.security.truststore=./conf/truststore.jks
nifi.security.truststoreType=jks
nifi.security.truststorePasswd=Ryz8DfwhIP0z4xZDyBo9wCmGKMejwk4J+DhMiEzyCm8

nifi.web.http.host=nifi.127.0.0.1.nip.io
nifi.web.http.port=8080
```

The `authorizers.xml` file will change infrequently, and it should contain blocks like these.  Note the `file-provider` identifier
appears in the properties above.

```xml
<authorizers>
    <userGroupProvider>
        <identifier>file-user-group-provider</identifier>
        <class>org.apache.nifi.authorization.FileUserGroupProvider</class>
        <property name="Users File">./conf/users.xml</property>
        <property name="Legacy Authorized Users File"></property>
        <property name="Initial User Identity 1">CN=admin, OU=NIFI</property>
    </userGroupProvider>

    <accessPolicyProvider>
        <identifier>file-access-policy-provider</identifier>
        <class>org.apache.nifi.authorization.FileAccessPolicyProvider</class>
        <property name="User Group Provider">file-user-group-provider</property>
        <property name="Authorizations File">./conf/authorizations.xml</property>
        <property name="Initial Admin Identity">admin@example.com</property>
        <property name="Legacy Authorized Users File"></property>
        <property name="Node Identity 1"></property>
        <property name="Node Group"></property>
    </accessPolicyProvider>

    <authorizer>
        <identifier>file-provider</identifier>
        <class>org.apache.nifi.authorization.FileAuthorizer</class>
        <property name="Authorizations File">./conf/authorizations.xml</property>
        <property name="Users File">./conf/users.xml</property>
        <property name="Initial Admin Identity">CN=admin, OU=NIFI</property>
        <property name="Legacy Authorized Users File"></property>
        <property name="Node Identity 1"></property>
    </authorizer>
</authorizers>
```


## Installation and Setup

This environment will contain a single NiFi instance running on the host, not in a container.  Setup is minimal 
and includes TLS certificates and keys.

Make a space for the installation:

```shell script
$ mkdir nifi-test
$ cd nifi-test
```

Then define the environment:

```shell script
$ export NIFI_HOST=nifi.127.0.0.1.nip.io
$ export OIDC_HOST=oidc.127.0.0.1.nip.io
```

Install [the NiFi Toolkit](https://nifi.apache.org/docs/nifi-docs/html/toolkit-guide.html) from [source](https://gitbox.apache.org/repos/asf?p=nifi.git) or a [binary release](https://nifi.apache.org/download.html).
Then use the toolkit to generate a keystore and truststore for the NiFi node:

```shell script
$ unzip nifi-toolkit-1.11.1-bin.zip
$ nifi-toolkit-1.11.1/bin/tls-toolkit.sh standalone -n $NIFI_HOST -C 'CN=admin, OU=NIFI' -O -o ./ssl-nifi -d 90
```


[Install NiFi](https://nifi.apache.org/docs/nifi-docs/html/getting-started.html#downloading-and-installing-nifi) from [source](https://gitbox.apache.org/repos/asf?p=nifi.git) or a [binary release](https://nifi.apache.org/download.html) and
copy the keystore and truststore files:

```shell script
$ unzip nifi-1.12.0-SNAPSHOT-bin.zip
$ cp ssl-nifi/nifi.127.0.0.1.nip.io/* nifi-1.12.0-SNAPSHOT/conf/ 
```

Modify `authorizers.xml` using the examples above before continuing.

f
Clone this repo and build the images:

```shell script
$ git clone git@github.com:natural/docker-nifi-oidc.git
$ cd docker-nifi-oidc
$ make builds
```

Next, generate certificates:

```
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout `pwd`/ssl-certs/oidc.127.0.0.1.nip.io.key -out `pwd`/ssl-certs/oidc.127.0.0.1.nip.io.crt -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName='DNS:oidc.127.0.0.1.nip.io'"))
```

Switch to the `services` directory so that the various docker files can reference the SSL certificates
by relative path, then start the services:

```shell script
$ cd services
$ docker-compose -f https-nifi up # For Ningx HTTPS for OIDC HTTP
```

Or:

```
$ docker-compose -f proxy-nifi up # For Nginx HTTPS for OIDC HTTP and NiFi HTTP
```


### Integration Overview

```shell script

```
keytool -importcert -file /Users/tmelhase/var/nifi-7328/docker-test-mozilla-django-oidc/proxy/ssl-certs/oidc.127.0.0.1.nip.io.crt -keystore ./truststore.jks -storepass "Ryz8DfwhIP0z4xZDyBo9wCmGKMejwk4J+DhMiEzyCm8"

* Add the SSL certificate created for the OIDC Provider your browser or operating system trust store
* Add the SSL certificate created for the OIDC Provider to the trust store used by the NiFi node


### Cleanup

* Stop docker services
* Remove docker containers
* Stop NiFi node
* Remove NiFi installation
* Remove SSL certificates
