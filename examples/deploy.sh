#!/bin/bash

### NOTE THIS RUNS THE IMAGE with 1GB memory space

SKIP_BUILD=true
APP_NAME=testapp
APP_WAR="$APP_NAME.war"

for ARG in "$@"
do
    IFS=\= read -a fields <<<"$ARG"
   
    key=$(printf ${fields[0]} | tr '[:lower:]' '[:upper:]')
    val="${fields[1]}"

    declare "$key=$val"
    echo "argument > $key = $val"
done

### check to make sure mandatory fields are set
if [ -z ${EXPOSED_PORT} ]; then
  echo "EXPOSED_PORT=<port number> is not set"
  exit;
fi;

if [ -z ${INTERNAL_PORT} ]; then
  echo "INTERNAL_PORT=<port number> is not set"
  exit;
fi;

if [ -z ${DB_HOST} ]; then
  echo "DB_HOST=<hostname:port> is not set"
  exit;
fi;

if [ -z ${ENV} ]; then
  echo "ENV=<prod or test or dev> is not set"
  exit;
fi;

echo "ENV: $ENV";
echo "EXPOSED_PORT: $EXPOSED_PORT";
echo "INTERNAL_PORT: $INTERNAL_PORT";
echo "DB_HOST: $DB_HOST";
echo "SKIP_BUILD: $SKIP_BUILD";

if [ "$SKIP_BUILD" == "true" ]; then
 echo "Skipping build of application";
else
  cd builds/$APP_NAME
  ./build-${ENV}.sh
  cd ../../
fi

### TODO 
WORKINGDIR=$ENV

## change directory to prod workingdir
cd $WORKINGDIR

NAME="$APP_NAME.webapp"
NODE="0"
VER=$(date +%Y%M%d.%H%M%S);
IMG_NAME="${NAME}.${ENV}.${VER}";
RUN_NAME="${NAME}.${ENV}.${NODE}.${VER}"
DOCKER_FILE="Dockerfile.${ENV}"

BUILD_PATH=../builds/$APP_NAME/
LOCAL_WAR_NAME=ROOT.war

cp $BUILD_PATH/target/$APP_WAR $LOCAL_WAR_NAME 

echo "Building image $IMG_NAME"

docker build -f "${DOCKER_FILE}" -t "${IMG_NAME}" .

### NOTE
## reserves 1gb
## this will add a host srv-db to the ip you specified, which can be used in your JNDI conf in server.xml
docker run --memory="1g" --detach=true -p $EXPOSED_PORT:$INTERNAL_PORT -e TZ=UTC --add-host=srv-db:$DB_HOST -it --name "${RUN_NAME}" "${IMG_NAME}"
