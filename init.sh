#!/bin/sh

CONF="/home/docker/xmrig/config.json"


echo "Project: xmrig ${MINERV}"
echo "Author:  lnxd"
echo "Base:    Ubuntu 20.04"
echo "Target:  Unraid"
echo ""

cd /home/docker/xmrig
sudo ./xmrig --url=$POOL --coin=$COIN --user=$WALLET.$WORKER --no-color

