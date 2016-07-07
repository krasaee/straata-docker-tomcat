sic Tomcat8 Docker Image + App Dockerfile

## 1. get the straata:java8 docker files 

```
git clone https://github.com/krasaee/straata-docker-java.git
cd straata-docker-java
./build.sh
```

## 2. get the straata:tomcat8 docker files

```
git clone https://github.com/krasaee/straata-docker-tomcat.git
cd straata-docker-tomcat
./build.sh
```

## 3. build your docker image against it.

Create a docker file for your app and do something like this (change it to your needs of course)...

```
FROM straata:tomcat8

WORKDIR $CATALINA_HOME
RUN set -x \
    && /bin/bash -c 'rm -rf $CATALINA_HOME/webapps/*' \
    && mkdir -p "$CATALINA_HOME/certs"

COPY "ROOT.war" "$CATALINA_HOME/webapps/ROOT.war"
COPY "certs/*" "$CATALINA_HOME/certs/"
COPY "conf/*.sh" "$CATALINA_HOME/bin/"
COPY "conf/*.xml" "$CATALINA_HOME/conf/"
COPY "lib/*.jar" "$CATALINA_HOME/lib/"
```


