#!/bin/sh

echo "Project:  xmrig ${MINERV}"
echo "Author:   lnxd"
echo "Base:     Ubuntu 20.04"
echo "Target:   Unraid"
echo "Donation: ${FEE} ${DONATE}%"
echo ""
echo "Running xmrig with the following flags:"
echo "--url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} ${ADDITIONAL}"
echo ""
echo "Running as ${USER} with IDs: $(id ${USER})"
echo ""
cd /home/docker/xmrig-${FEE}
./xmrig --url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} --donate-level=${DONATE} ${ADDITIONAL}

