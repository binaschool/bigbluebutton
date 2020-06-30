#!/bin/bash
# 
# Please set the following environment variables before running the script
# BBB_SERVER="staging.example.com"

BBB_URL=wss://${BBB_SERVER}/bbb-webrtc-sfu

CONTAINER_IMAGE=bbb-html5
VERSION=0.2

CONTAINER_NAME=bbb-html5

# Build meteor archive docker container
docker build -t ${CONTAINER_IMAGE}:${VERSION} -f Dockerfile-archive --build-arg bbb_url=${BBB_URL} .

echo "--------------------"
echo "Creating container for archive extraction"
CONTAINER=$(docker create --name ${CONTAINER_NAME} ${CONTAINER_IMAGE}:${VERSION})

echo "Copying archive from container"
docker cp ${CONTAINER}:/home/meteor/meteorbundle/source.tar.gz source.tar.gz

echo "Deleting container image"
docker rm -f ${CONTAINER}

echo "Copy archive to ${BBB_SERVER}"
scp source.tar.gz root@${BBB_SERVER}:/root/source.tar.gz

echo "Stop existing bbb-html5 service, untar archive and start the service again"

ssh root@${STAGING_SERVER} << EOF 
  systemctl stop bbb-html5
  tar -xvzf /root/source.tar.gz -C /usr/share/meteor
  systemctl start bbb-html5
  systemctl status bbb-html5
EOF

