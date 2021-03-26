# xmrig 6.10.0 on alpine 3.9

An example `docker run` command:

```
docker run -d \
--name="xmrig" \
-e TZ="Australia/Melbourne" \
-e COIN="monero" \
-e POOL="randomxmonero.usa-west.nicehash.com:3380" \
-e WALLET="3QGJuiEBVHcHkHQMXWY4KZm63vx1dEjDpL" \
-e WORKER="Docker" xmrig
```