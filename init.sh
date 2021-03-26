#!/bin/sh

CONF="/home/docker/xmrig/config.json"


echo "Project: xmrig ${MINERV}"
echo "Author:  lnxd"
echo "Base:    Alpine 3.9"
echo "Target:  Unraid"
echo ""

rm $CONF
cp /home/docker/config.json.example $CONF

#sed -i '/enabled/c\   \"enabled\" : \"true\",'  $CONF
#sed -i '/port/c\   \"port\" : \"80\",'  $CONF

sed -i '/coin/c\   \"coin\" : \"'${COIN}'\",'  $CONF
sed -i '/url/c\   \"url\" : \"'${POOL}'\",'  $CONF
sed -i '/user/c\   \"user\" : \"'${WALLET}.${WORKER}'\",'  $CONF


cd /home/docker/xmrig
sudo ./xmrig

