FROM alpine:3.9

ENV MINERV="6.10.0"
ENV APPS="curl tar gzip"

# Prepare alpine
RUN apk add --no-cache ${APPS}; \
    adduser \
    --disabled-password \
    --gecos "" \
    "docker";\
    echo 'docker:docker' | chpasswd; \
    addgroup sudo; \
    adduser docker sudo; \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers;
ENV HOME /home/docker
WORKDIR /home/docker

COPY "init.sh" "/home/docker/init.sh"
RUN chmod +x /home/docker/init.sh

RUN curl "https://github.com/xmrig/xmrig/releases/download/v${MINERV}/xmrig-${MINERV}-linux-static-x64.tar.gz" -L -o "/home/docker/xmrig-${MINERV}-linux-static-x64.tar.gz"; \
    tar xvzf xmrig-${MINERV}-linux-static-x64.tar.gz; \
    rm xmrig-${MINERV}-linux-static-x64.tar.gz; \
    mv xmrig-${MINERV} xmrig; \
    chmod +x /home/docker/xmrig/xmrig;

WORKDIR /home/docker

CMD ["./init.sh"]