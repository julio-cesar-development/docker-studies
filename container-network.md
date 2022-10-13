# Docker container network

> Custom networks provide automatic service discovery, using the Docker embedded DNS server

Useful links:
- [https://docs.docker.com/network/#default-networks](https://docs.docker.com/network/#default-networks)
- [https://docs.docker.com/engine/reference/commandline/network_create/](https://docs.docker.com/engine/reference/commandline/network_create/)
- [https://www.aquasec.com/cloud-native-academy/docker-container/docker-networking/](https://www.aquasec.com/cloud-native-academy/docker-container/docker-networking/)
- [https://earthly.dev/blog/docker-networking/](https://earthly.dev/blog/docker-networking/)


## Listing networks

```bash
docker network ls
```


# network HOST

```bash
docker container run --rm --name debian --net host debian:10 bash -c "ip a"
# IPs from host

docker container run --rm -d --name nginx --net host nginx:1-alpine
docker container logs -f nginx
curl -i http://localhost
```


## network NONE

```bash
docker container run --rm --name debian --net none debian:10 bash -c "ip a"
# only have loopback interface
docker container run --rm --name debian --net none debian:10 bash -c "ping google.com"
```


## network BRIDGE

```bash
# default bridge

docker network inspect bridge
# "172.17.0.0/16"
docker network inspect bridge | grep "com.docker.network.bridge.name"
# docker0

# running on default bridge network (docker0)
docker container run --rm --net bridge debian:10 bash -c "ip a"

docker container run --rm --net bridge debian:10 bash -c "ping 172.17.0.1"

eth0@if173: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
   valid_lft forever preferred_lft forever
 
ip a | grep -A3 "docker0:"
docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
link/ether 02:42:6a:e1:5e:46 brd ff:ff:ff:ff:ff:ff
inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
   valid_lft forever preferred_lft forever


# running on default bridge network (docker0)
docker container run -d -it --name debian --rm --net bridge debian:10
docker container exec -it debian bash -c "ip a"
docker container inspect --format='{{json .NetworkSettings.Networks}}' debian


docker network disconnect bridge debian
docker container exec -it debian bash -c "ip a"
# somente IP loopback 127.0.0.1
docker container exec -it debian bash -c "ping google.com"

docker network disconnect bridge debian


# https://docs.docker.com/network/overlay/#publish-ports

docker container run --rm -d --name nginx --net bridge --publish 80:80/tcp nginx:1-alpine
docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx
docker container logs -f nginx
curl -i http://localhost

tcpdump -i [interface] -Q in -vv

# listening packets on docker0 interface
tcpdump -i docker0 -Q in -n port 80 -vv

# show packet content
tcpdump -i docker0 -Q in -vv -Q in -vv
```


## custom network bridge

```bash
docker network create \
  -o "com.docker.network.bridge.name"="br-bridge-net" \
  -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" \
  --subnet 172.200.0.0/24 \
  --gateway 172.200.0.1 \
  --driver bridge \
  bridge-net

docker network inspect bridge-net
ip a | grep -A4 'br-bridge-net'

# first container
docker container run -d \
  --rm -it \
  --name alpine1 \
  --hostname alpine1 \
  --network bridge-net \
  --ip 172.200.0.2 \
  alpine:3.12.0

docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' alpine1
# 172.200.0.2

docker container exec -it alpine1 sh -c "ping google.com"


# second container
docker container run -d \
  --rm -it \
  --name alpine2 \
  --hostname alpine2 \
  --network bridge-net \
  --ip 172.200.0.3 \
  alpine:3.12.0

docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' alpine2
# 172.200.0.3

# hostname resolution between containers only works on custom networks
docker container exec -it alpine2 sh -c "ping alpine1"
docker container exec -it alpine2 sh -c "nslookup alpine1"


# disconnect a container from a network
docker network disconnect bridge-net alpine1

docker container inspect --format='{{json .NetworkSettings.Networks}}' alpine1

docker network connect bridge-net alpine1


docker container run --rm -d --name nginx --net bridge-net --publish 80:80/tcp nginx:1-alpine
tcpdump -i br-bridge-net -Q in -n port 80 -vv
```


## custom network with host added to /etc/hosts

```bash
# third container (with add-host)
docker container run -d \
  --rm -it \
  --name alpine3 \
  --hostname alpine3 \
  --network bridge-net \
  --add-host=host.local:172.16.0.2 \
  --ip 172.200.0.4 \
  alpine:3.12.0

docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' alpine3
# 172.200.0.4

docker container exec -it alpine3 sh -c "ping host.local"

docker container exec -it alpine3 sh -c "cat /etc/hosts"
# 172.16.0.2      host.local
```
