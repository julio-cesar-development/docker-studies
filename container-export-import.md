# Container export and import

```bash
# run some container in background
docker container run \
  --rm -i -d \
  --name alpine \
  alpine:3.12.0 sh

# add some extra packages
docker exec -it alpine sh -c "apk update && apk add curl && apk add jq"

# try out these packages
docker exec -it alpine \
  sh -c "curl --silent https://api.bitcointrade.com.br/v3/public/BRLBTC/ticker | jq . > /usr/local/bitcoin.json"

docker exec -it alpine sh -c "cat /usr/local/bitcoin.json"


# export container
docker export alpine -o ./alpine.tar

# import container
docker import ./alpine.tar


# extract files from the container filesystem into a directory
mkdir -p ./rootfs && \
  tar xf ./alpine.tar --ignore-command-error -C ./rootfs/

# unshare the current namespace, doing a chroot in the end to enter in a new namespace using the filesystem of the exported container
unshare \
  --mount \
  --uts \
  --ipc \
  --net \
  --pid \
  --fork \
  --user \
  --map-root-user \
  chroot ./rootfs sh

# mount some directories to isolate
mount -t proc none /proc
mount -t tmpfs none /tmp
mount -t devpts none /dev/pts
mount -t tmpfs none /run
mount -t sysfs none /sys


cat /etc/os-release
# NAME="Alpine Linux"
# ID=alpine
# VERSION_ID=3.12.0
# PRETTY_NAME="Alpine Linux v3.12"
# HOME_URL="https://alpinelinux.org/"
# BUG_REPORT_URL="https://bugs.alpinelinux.org/"


# cleanup
docker container rm -f alpine


# another way
mkdir -p ./rootfs
docker export $(docker create alpine:3.12.0) | tar -C ./rootfs/ -xvf -

```
