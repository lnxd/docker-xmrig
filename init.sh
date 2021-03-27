#!/bin/sh

CONF="/home/docker/xmrig/config.json"


echo "Project: xmrig ${MINERV}"
echo "Author:  lnxd"
echo "Base:    Alpine 3.9"
echo "Target:  Unraid"
echo ""

cd /home/docker/xmrig
sudo ./xmrig --url=$POOL --coin=$COIN --user=$WALLET.$WORKER --no-color

