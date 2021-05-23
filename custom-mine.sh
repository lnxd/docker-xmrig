#!/bin/bash

echo "---Starting---"
echo ""
echo "Project: XMRig $MINERV"
echo "Author:  lnxd"
echo "Base:    $BASE"
echo "Driver:  $INSTALLED_DRIVERV"
echo "Target:  Unraid 6.9.0 - 6.9.2"
echo
echo "+---- WARNING ---- WARNING ---- WARNING ---- WARNING ---- WARNING ----"
echo "| You are running XMRig in custom mode!"
echo "| Please make sure that you entered all necessary values correctly"
echo "+---- WARNING ---- WARNING ---- WARNING ---- WARNING ---- WARNING ----"
echo
echo "Custom command:  $ADDITONAL"
echo
echo "Starting XMRig $MINERV as $(id) with the following arguments:"
echo "$ADDITIONAL"
echo
cd /home/docker/xmrig-${FEE}
./xmrig ${ADDITIONAL}
