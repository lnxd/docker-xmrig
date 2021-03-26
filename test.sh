#!/bin/bash

docker stop xmrig
docker rm xmrig
docker build . -t xmrig
docker run -d -e TZ="Australia/Melbourne" -p 127.0.0.1:80:80/tcp --name="xmrig" xmrig
docker logs xmrig -f