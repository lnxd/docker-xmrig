ARG BASE

FROM ubuntu:${BASE:-20.04} AS xmrig-build-base

# Install default apps
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y apt-utils; \
    apt-get install -y curl sudo libpci3 xz-utils wget kmod git build-essential cmake automake libtool autoconf libuv1-dev libssl-dev libhwloc-dev; \
# Clean up apt
    apt-get clean all; \
# Set timezone
    ln -fs /usr/share/zoneinfo/Australia/Melbourne /etc/localtime; \
    apt-get install -y tzdata; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
# Prevent error messages when running sudo
    echo "Set disable_coredump false" >> /etc/sudo.conf; \
# Create user account
    useradd docker; \
    echo 'docker:docker' | sudo chpasswd; \
    usermod -aG sudo docker; \
    mkdir /home/docker;

# Set environment variables.
ENV HOME /home/docker

# Define working directory.
WORKDIR /home/docker

###############
#  Build dev  #
###############

FROM xmrig-build-base AS xmrig-dev-fee

ENV SOURCE="--depth 1 https://github.com/lnxd/xmrig.git"

RUN git clone $SOURCE; \
    mkdir xmrig/build && cd xmrig/scripts; \
    ./build_deps.sh && cd ../build; \
    cmake .. -DXMRIG_DEPS=scripts/deps; \
    make -j$(nproc)

###############
#  Build lnxd #
###############

FROM xmrig-build-base AS xmrig-lnxd-fee

ENV SOURCE="--depth 1 --branch lnxd-fee https://github.com/lnxd/xmrig.git"

RUN git clone $SOURCE; \
    mkdir xmrig/build && cd xmrig/scripts; \
    ./build_deps.sh && cd ../build; \
    cmake .. -DXMRIG_DEPS=scripts/deps; \
    make -j$(nproc)

###############
#   Build no  #
###############

FROM xmrig-build-base AS xmrig-no-fee

ENV SOURCE="--depth 1 --branch no-fee https://github.com/lnxd/xmrig.git"

RUN git clone $SOURCE; \
    mkdir xmrig/build && cd xmrig/scripts; \
    ./build_deps.sh && cd ../build; \
    cmake .. -DXMRIG_DEPS=scripts/deps; \
    make -j$(nproc)

###############
#  Build Cuda #
###############

FROM nvidia/cuda:11.2.2-devel-ubuntu20.04 AS xmrig-cuda

ENV SOURCE="https://github.com/xmrig/xmrig-cuda.git"

# Set timezone
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    ln -fs /usr/share/zoneinfo/Australia/Melbourne /etc/localtime; \
    apt-get install -y tzdata; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
    apt-get clean all

# Install default apps
RUN export DEBIAN_FRONTEND=noninteractive;\
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y apt-utils; \
    apt-get install -y git build-essential cmake automake libtool autoconf libuv1-dev libssl-dev libhwloc-dev; \
    apt-get clean all;

# Create user account
RUN useradd docker; \
    echo 'docker:docker' | chpasswd; \
    usermod -aG sudo docker; \
    mkdir /home/docker

# Set environment variables.
ENV HOME /home/docker

# Define working directory.
WORKDIR /home/docker

RUN echo "Running git clone ${SOURCE}"; \
    git clone $SOURCE; \
    mkdir xmrig-cuda/build && cd xmrig-cuda/build; \
    cmake .. -DCUDA_LIB=/usr/local/cuda/lib64/stubs/libcuda.so -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda; \
    make -j$(nproc); \
    ls -lh

###############
#  Build Main #
###############

FROM nvidia/cuda:11.2.2-devel-ubuntu20.04

# Set timezone and create user
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    ln -fs /usr/share/zoneinfo/Australia/Melbourne /etc/localtime; \
    apt-get install -y tzdata; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
    apt-get clean all; \
    # Create user account
    groupadd -g 98 docker; \
    useradd --uid 99 --gid 98 docker; \
    echo 'docker:docker' | chpasswd;

# Install default apps
# Copy latest scripts
COPY start.sh mine.sh custom-mine.sh /home/docker/
RUN chmod +x /home/docker/start.sh; \
    chmod +x /home/docker/mine.sh; \
    chmod +x /home/docker/custom-mine.sh; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends libuv1-dev libssl-dev libhwloc-dev curl ca-certificates libpci3 xz-utils wget; \
    apt-get autoremove -y; \
    apt-get clean all;

# Prepare xmrig
WORKDIR /home/docker
COPY --from=xmrig-cuda /home/docker/xmrig-cuda/build/libxmrig-cuda.so /home/docker/libxmrig-cuda.so
COPY --from=xmrig-dev-fee /home/docker/xmrig/build/xmrig /home/docker/xmrig-dev-fee/xmrig
COPY --from=xmrig-lnxd-fee /home/docker/xmrig/build/xmrig /home/docker/xmrig-lnxd-fee/xmrig
COPY --from=xmrig-no-fee /home/docker/xmrig/build/xmrig /home/docker/xmrig-no-fee/xmrig
RUN chmod +x /home/docker/xmrig-dev-fee/xmrig ; \
    chmod +x /home/docker/xmrig-lnxd-fee/xmrig; \
    chmod +x /home/docker/xmrig-no-fee/xmrig; \
    ln -s /home/docker/libxmrig-cuda.so /home/docker/xmrig-dev-fee/libxmrig-cuda.so; \
    ln -s /home/docker/libxmrig-cuda.so /home/docker/xmrig-lnxd-fee/libxmrig-cuda.so; \
    ln -s /home/docker/libxmrig-cuda.so /home/docker/xmrig-no-fee/libxmrig-cuda.so; 

ENV COIN="monero"
ENV POOL="xmr.2miners.com:2222"
ENV WALLET="84e8UJvXHDGVfE5HZDQfhn3Kh3RGJKebz31G7D4H24TLPMe9x7bQLBw8iyBhNx9USXB8MhvhBe3DyVW1LcuVAf4jBiADNLw"
ENV WORKER="Docker"
ENV HOME="/home/docker"
ENV FEE="lnxd-fee" 
ENV DRIVERV=""
# Fee options: "lnxd-fee", "dev-fee", "no-fee"

USER root

CMD ["./start.sh"]