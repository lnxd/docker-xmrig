FROM ubuntu:20.04

ENV COIN="monero"
ENV POOL="randomxmonero.usa-west.nicehash.com:3380"
ENV WALLET="3QGJuiEBVHcHkHQMXWY4KZm63vx1dEjDpL"
ENV WORKER="Docker"
ENV APPS="curl tar gzip libuv1-dev libssl-dev libhwloc-dev"
ENV HOME="/home/docker"

# Set timezone
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    ln -fs /usr/share/zoneinfo/Australia/Melbourne /etc/localtime; \
    apt-get install -y tzdata; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
    apt-get clean all

# Install default apps
COPY "init.sh" "/home/docker/init.sh"
RUN export DEBIAN_FRONTEND=noninteractive; \
    chmod +x /home/docker/init.sh; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y sudo $APPS; \
    apt-get clean all; \

# Prevent error messages when running sudo
    echo "Set disable_coredump false" >> /etc/sudo.conf

# Create user account
RUN useradd docker; \
    echo 'docker:docker' | chpasswd; \
    usermod -aG sudo docker; \
    mkdir /home/docker

# Prepare xmrig
WORKDIR /home/docker
RUN FEE="dev-fee"; \
    curl "https://github.com/lnxd/xmrig/releases/download/v6.10.0/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig ;\
    FEE="no-fee"; \
    curl "https://github.com/lnxd/xmrig/releases/download/v6.10.0/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig ;\
    FEE="lnxd-fee"; \
    curl "https://github.com/lnxd/xmrig/releases/download/v6.10.0/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig

CMD ["./init.sh"]