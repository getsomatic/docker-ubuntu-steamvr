#!/usr/bin/env bash

DOCKER=docker
echo -n "Checking if we can communicate with docker..."
if ! docker info >/dev/null 2>&1; then
    echo "No!"
    echo -n "Unable to use docker directly. Trying sudo docker..."
    if sudo docker info >/dev/null 2>&1; then
	echo "YES!"
	echo "sudo docker worked. Proceeding..."
	DOCKER='sudo docker'
    else
	echo "NO!"
	echo "Unable to run docker info or sudo docker. Please fix and retry."
	exit 3
    fi
else
    echo "YES!"
fi

echo "Searching for Docker image ..."
declare -i CONFIGURED=0
DOCKER_IMAGE_ID=$($DOCKER images --format="{{.ID}}" docker-ubuntu-steamvr-configured:latest | head -n 1)
if [ -z $DOCKER_IMAGE_ID ]; then
    DOCKER_IMAGE_ID=$($DOCKER images --format="{{.ID}}" docker-ubuntu-steamvr:latest | head -n 1)
    if [ -z $DOCKER_IMAGE_ID ]; then
	echo "Both docker-ubuntu-steamvr-configured:latest and docker-ubuntu-steamvr:latest were not found."
	echo "Try running sudo ./build.sh to create image docker-ubuntu-steamvr:latest.\n"
	exit 1
    else
	echo "Using image docker-ubuntu-steamvr:latest"
	echo "It will commit changes after this run to image docker-ubuntu-steamvr-configured:latest"
    fi
else
    echo "Using image docker-ubuntu-steamvr-configured:latest"
    CONFIGURED=1
fi
echo "Found and using ${DOCKER_IMAGE_ID}"

USER_UID=$(id -u)

if [ $USER_UID -eq 0 ]; then
    USER_UID=1000
fi

if [ -z $XAUTHORITY ]; then
    echo "No XAUTHORITY environment variable found. Please define one so we know which file to copy into container"
    exit 2
fi

VSHARES="--volume=/run/user/${USER_UID}/pulse/:/run/user/1000/pulse/"
VSHARES="$VSHARES --volume=/tmp/.X11-unix/:/tmp/.X11-unix/"
if [ -n $STEAMLIBRARY ]; then
    VSHARES="$VSHARES --volume=$STEAMLIBRARY:$STEAMLIBRARY"
fi

$DOCKER container stop steamvr
$DOCKER container rm steamvr

$DOCKER create -t -i \
  --name steamvr \
  $VSHARES \
  -e DISPLAY=:0.0 \
  --network=host \
  --ipc=host \
  --privileged \
  ${DOCKER_IMAGE_ID} \
  ${@}

TMPFILE=$(mktemp)
cp $XAUTHORITY $TMPFILE
chown $USER_UID $TMPFILE
$DOCKER cp $TMPFILE steamvr:/home/steam/.Xauthority
$DOCKER cp $TMPFILE steamvr:/root/.Xauthority
rm $TMPFILE

$DOCKER start steamvr
$DOCKER exec steamvr chown $USER_UID:$USER_UID /home/steam/.Xauthority

$DOCKER exec -i --privileged -t -u steam steamvr steam
$DOCKER container stop steamvr
if [ $CONFIGURED -ne 1 ]; then
    $DOCKER commit steamvr docker-ubuntu-steamvr-configured
else
    echo "Changes not saved yet. To commit run $DOCKER commit steamvr docker-ubuntu-steamvr-configured:latest"
fi
