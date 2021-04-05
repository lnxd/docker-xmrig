#!/bin/sh

echo "Project:  XMRig ${MINERV}"
echo "Author:   lnxd"
echo "Base:     Ubuntu 20.04"
echo "Target:   Unraid"
echo "Donation: ${FEE} ${DONATE}%"
echo ""
echo "Running xmrig with the following flags:"
echo "--url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} ${ADDITIONAL}"
echo ""
cd /home/docker/xmrig-${FEE}
if [ $SUDO = "true" ]; then
   sudo ./xmrig --url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} --donate-level=${DONATE} ${ADDITIONAL}
else
  ./xmrig --url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} --donate-level=${DONATE} ${ADDITIONAL}
fi

