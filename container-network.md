# Docker container network

> Custom networks provide automatic service discovery, using the Docker embedded DNS server

```bash
# create a custom network
docker network create \
  --subnet 172.100.0.0/24 \
  --gateway 172.100.0.1 \
  --driver bridge \
  custom-net

# first container
docker container run \
  --rm -it \
  --name alpine1 \
  --network custom-net \
  alpine:3.12.0 sh

# second container
docker container run \
  --rm -it \
  --name alpine2 \
  --network custom-net \
  alpine:3.12.0 sh

# ping alpine1

# PING alpine1 (172.100.0.2): 56 data bytes
# 64 bytes from 172.100.0.2: seq=0 ttl=64 time=0.373 ms
# 64 bytes from 172.100.0.2: seq=1 ttl=64 time=0.171 ms
# ...


# nslookup alpine1

# Name: alpine1
# Address: 172.100.0.2



ip -4 addr show scope global dev enp4s0

# third container (with add-host)
docker container run \
  --rm -it \
  --name alpine3 \
  --network custom-net \
  --add-host=ubuntu:172.16.0.103 \
  alpine:3.12.0 sh

# ping ubuntu


/etc/hosts

/etc/resolv.conf

/run/systemd/resolve/resolv.conf

nsenter -n -t $(docker inspect --format {{.State.Pid}} alpine1) \
  iptables -t nat -nvL
```
