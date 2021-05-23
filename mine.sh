#!/bin/bash

echo "---Starting---"
echo ""
echo "Project:      XMRig ${MINERV}"
echo "Author:       lnxd"
echo "Base:         Ubuntu 20.04"
echo "Target:       Unraid 6.9.0 - 6.9.2"
echo "Donation:     ${FEE} ${DONATE}%"
echo "Driver:       $INSTALLED_DRIVERV"
echo ""
echo "Running xmrig with the following flags:"
echo "--url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} --randomx-wrmsr=-1 --randomx-no-rdmsr ${ADDITIONAL}"
echo ""
cd /home/docker/xmrig-${FEE}
./xmrig --url=${POOL} --coin=${COIN} --user=${WALLET}.${WORKER} --donate-level=${DONATE} --randomx-wrmsr=-1 --randomx-no-rdmsr ${ADDITIONAL}
