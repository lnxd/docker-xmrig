#!/bin/bash
echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
	chmod +x /opt/scripts/user.sh
	/opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

export DATA_DIR=$HOME

uninstall_amd_driver() {
	if [ -f /usr/bin/amdgpu-uninstall ]; then
		echo "Uninstalling driver"
		echo 'APT::Get::Assume-Yes "true";' >>/etc/apt/apt.conf.d/90assumeyes
		/usr/bin/amdgpu-uninstall
		rm /etc/apt/apt.conf.d/90assumeyes
		echo "Done!"
	else
		echo "---AMD driver not present---"
	fi
}

install_amd_driver() {
	AMD_DRIVER=$1
	AMD_DRIVER_URL=$2
	FLAGS=$3
	echo "---Installing AMD drivers, please wait!---"
	echo "---Downloading driver from "$AMD_DRIVER_URL/$AMD_DRIVER"---"
	echo 'APT::Get::Assume-Yes "true";' >>/etc/apt/apt.conf.d/90assumeyes
	mkdir -p /tmp/opencl-driver-amd
	cd /tmp/opencl-driver-amd
	#echo AMD_DRIVER is $AMD_DRIVER
	curl --referer $AMD_DRIVER_URL -O $AMD_DRIVER_URL/$AMD_DRIVER
	tar -Jxf $AMD_DRIVER &>/dev/null
	rm $AMD_DRIVER
	cd amdgpu-pro-*
	echo "---Installing driver, this can take a very long time with no output. Please wait!---"
	apt-get install -y initramfs-tools &>/dev/null
	./amdgpu-pro-install $FLAGS &>/dev/null
	apt-get --fix-broken install -y &>/dev/null
	cd /home/docker/
	rm -rf /tmp/opencl-driver-amd
	echo "---AMD Driver installation finished---"
	INSTALLED_DRIVERV=0
	rm /etc/apt/apt.conf.d/90assumeyes
}

INSTALLED_DRIVERV=0

if [[ "${INSTALLED_DRIVERV}" != "${DRIVERV:-0}" ]]; then

	case $DRIVERV in

	0)
		uninstall_amd_driver
		echo "---Skipping AMD driver installation---"
		;;

	18.20)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-18.20-673703-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	18.30)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-18.30-641594.tar.xz" "https://drivers.amd.com/drivers/linux/ubuntu/18.04" "--opencl=legacy,pal --headless"
		;;

	18.40)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-18.40-697810-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	18.50)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-18.50-756341-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	19.10)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-19.10-785425-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	19.20)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-19.20-812932-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	19.30)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-19.30-934563-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	19.50)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-19.50-967956-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	20.10)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	20.20)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-20.20-1098277-ubuntu-20.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	20.30)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-20.30-1109583-ubuntu-20.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	20.40)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-20.40-1147286-ubuntu-20.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	20.45)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-20.45-1188099-ubuntu-20.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,pal --headless"
		;;

	20.50)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-20.50-1234664-ubuntu-20.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=legacy,rocr --headless"
		;;

	21.10)
		uninstall_amd_driver
		install_amd_driver "amdgpu-pro-21.10-1247438-ubuntu-20.04.tar.xz" "https://drivers.amd.com/drivers/linux" "--opencl=rocr,legacy --headless"
		;;
	esac

fi

if [ -f /usr/bin/nvidia-smi ]; then
	echo "---Detected Nvidia card, installing driver, please wait!---"
	if [ -z "${NV_DRV_V}" ]; then
		echo "---Trying to get Nvidia driver version---"
		export NV_DRV_V="$(nvidia-smi | grep NVIDIA-SMI | cut -d ' ' -f3)"
		if [ -z "${NV_DRV_V}" ]; then
			echo "---Something went wrong, can't get driver version, putting container into sleep mode---"
			sleep infinity
		else
			echo "---Successfully got driver version: ${NV_DRV_V}---"
		fi
	fi

	if [ ! -z "$INSTALL_V" ]; then
		if [ "$INSTALL_V" != "${NV_DRV_V}" ]; then
			echo "---Version missmatch, deleting local Nvidia Driver v$INSTALL_V---"
			rm ${DATA_DIR}/NVIDIA_$INSTALL_V.run
		fi
	fi

	INSTALL_V="$(find ${DATA_DIR} -name NVIDIA_*\.run | cut -d '_' -f 2 | cut -d '.' -f1- | sed 's/\.[^.]*$//')"

	if [ ! -z "$INSTALL_V" ]; then
		if [ "$INSTALL_V" != "${NV_DRV_V}" ]; then
			echo "---Version missmatch, deleting local Nvidia Driver v$INSTALL_V---"
			rm ${DATA_DIR}/NVIDIA_$INSTALL_V.run
		fi
	fi

	if [ ! -f /usr/bin/nvidia-settings ]; then
		if [ -f ${DATA_DIR}/NVIDIA_${NV_DRV_V}.run ]; then
			echo "---Found NVIDIA Driver v${NV_DRV_V} locally, installing...---"
			${DATA_DIR}/NVIDIA_${NV_DRV_V}.run ${NVIDIA_BUILD_OPTS} >/dev/null 2>&1
		else
			echo "---Downloading and installing Nvidia Driver v${NV_DRV_V}---"
			wget -q --show-progress --progress=bar:force:noscroll -O /tmp/NVIDIA.run http://download.nvidia.com/XFree86/Linux-x86_64/${NV_DRV_V}/NVIDIA-Linux-x86_64-${NV_DRV_V}.run &&
				chmod +x /tmp/NVIDIA.run &&
				/tmp/NVIDIA.run ${NVIDIA_BUILD_OPTS} >/dev/null 2>&1 &&
				mv /tmp/NVIDIA.run ${DATA_DIR}/NVIDIA_${NV_DRV_V}.run
		fi
	else
		CUR_NV_DRV_V=$INSTALL_V
		if [ "$NV_DRV_V" != "$CUR_NV_DRV_V" ]; then
			echo "---Driver version missmatch, currently installed: v$CUR_NV_DRV_V, driver on Host: v$NV_DRV_V---"
			if [ -f ${DATA_DIR}/NVIDIA_${NV_DRV_V}.run ]; then
				echo "---Found NVIDIA Driver v${NV_DRV_V} locally, installing...---"
				${DATA_DIR}/NVIDIA_${NV_DRV_V}.run ${NVIDIA_BUILD_OPTS} >/dev/null 2>&1
			else
				echo "---Downloading and installing Nvidia Driver v${NV_DRV_V}---"
				wget -q --show-progress --progress=bar:force:noscroll -O /tmp/NVIDIA.run http://download.nvidia.com/XFree86/Linux-x86_64/${NV_DRV_V}/NVIDIA-Linux-x86_64-${NV_DRV_V}.run &&
					chmod +x /tmp/NVIDIA.run &&
					/tmp/NVIDIA.run ${NVIDIA_BUILD_OPTS} >/dev/null 2>&1 &&
					mv /tmp/NVIDIA.run ${DATA_DIR}/NVIDIA_${NV_DRV_V}.run
			fi
		else
			echo "---Nvidia Driver v$CUR_NV_DRV_V Up-To-Date---"
		fi
	fi
fi

term_handler() {
	kill -SIGTERM "$killpid"
	wait "$killpid" -f 2>/dev/null

	exit 143
}

trap 'kill ${!}; term_handler' SIGTERM
if [ "${CUSTOM}" == "true" ]; then
	/home/docker/custom-mine.sh &
else
	/home/docker/mine.sh &
fi
killpid="$!"

while true; do
	wait $killpid
	exit 0
done
