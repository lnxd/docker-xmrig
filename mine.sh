#!/bin/sh

echo "Project:  xmrig ${MINERV}"
echo "Author:   lnxd"
echo "Base:     Ubuntu 20.04"
echo "Target:   Unraid"
echo "Donation: ${FEE} ${DONATE}%"
echo ""
echo "Running xmrig as $(id) with the following flags:"
echo "--url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} --randomx-wrmsr=-1 --randomx-no-rdmsr ${ADDITIONAL}"

cd /home/docker/xmrig-${FEE}
./xmrig --url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} --donate-level=${DONATE} --randomx-wrmsr=-1 --randomx-no-rdmsr ${ADDITIONAL}
