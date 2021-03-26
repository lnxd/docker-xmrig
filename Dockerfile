FROM alpine:3.9

# Prepare alpine
RUN apk add --no-cache curl; \
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

