#!/bin/bash

docker stop xmrig
docker rm xmrig
docker build . -t xmrig
docker run --name="xmrig" xmrig