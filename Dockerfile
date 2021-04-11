FROM ubuntu:20.04 AS xmrig-build-base

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
    apt-get install -y wget git build-essential cmake automake libtool autoconf libuv1-dev libssl-dev libhwloc-dev; \
    apt-get clean all;

# Create user account
RUN useradd docker; \
    echo 'docker:docker' | chpasswd; \
    mkdir /home/docker

# Set environment variables.
ENV HOME /home/docker

# Define working directory.
WORKDIR /home/docker

FROM xmrig-build-base AS xmrig-dev-fee

ENV SOURCE="--depth 1 https://github.com/lnxd/xmrig.git"

RUN git clone $SOURCE; \
    mkdir xmrig/build && cd xmrig/scripts; \
    ./build_deps.sh && cd ../build; \
    cmake .. -DXMRIG_DEPS=scripts/deps; \
    make -j$(nproc)

FROM xmrig-build-base AS xmrig-lnxd-fee

ENV SOURCE="--depth 1 --branch lnxd-fee https://github.com/lnxd/xmrig.git"

RUN git clone $SOURCE; \
    mkdir xmrig/build && cd xmrig/scripts; \
    ./build_deps.sh && cd ../build; \
    cmake .. -DXMRIG_DEPS=scripts/deps; \
    make -j$(nproc)

FROM xmrig-build-base AS xmrig-no-fee

ENV SOURCE="--depth 1 --branch no-fee https://github.com/lnxd/xmrig.git"

RUN git clone $SOURCE; \
    mkdir xmrig/build && cd xmrig/scripts; \
    ./build_deps.sh && cd ../build; \
    cmake .. -DXMRIG_DEPS=scripts/deps; \
    make -j$(nproc)

FROM ubuntu:20.04

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
COPY start.sh /home/docker/start.sh
COPY mine.sh /home/docker/mine.sh
RUN export DEBIAN_FRONTEND=noninteractive; \
    chmod +x /home/docker/mine.sh; \
    chmod +x /home/docker/start.sh; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends libuv1-dev libssl-dev libhwloc-dev curl libpci3 xz-utils; \
    apt-get autoremove -y; \
    apt-get clean all;

# Prepare xmrig
WORKDIR /home/docker
COPY --from=xmrig-dev-fee /home/docker/xmrig /home/docker/xmrig-dev-fee/xmrig
COPY --from=xmrig-lnxd-fee /home/docker/xmrig /home/docker/xmrig-lnxd-fee/xmrig
COPY --from=xmrig-no-fee /home/docker/xmrig /home/docker/xmrig-no-fee/xmrig
RUN chmod +x /home/docker/xmrig-dev-fee/xmrig ; \
    chmod +x /home/docker/xmrig-lnxd-fee/xmrig; \
    chmod +x /home/docker/xmrig-no-fee/xmrig;

ENV COIN="monero"
ENV POOL="randomxmonero.usa-west.nicehash.com:3380"
ENV WALLET="3QGJuiEBVHcHkHQMXWY4KZm63vx1dEjDpL"
ENV WORKER="Docker"
ENV HOME="/home/docker"
ENV FEE="lnxd-fee" 
ENV DRIVERV=""
# Fee options: "lnxd-fee", "dev-fee", "no-fee"

USER root

CMD ["./mine.sh"]