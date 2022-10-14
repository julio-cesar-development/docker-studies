# Docker volumes

## list volumes

```bash
docker volume ls
```

## named volumes

```bash
# create a new volume called "named-volume-test"
docker volume create named-volume-test

# place where docker persists its files
docker info | grep "Docker Root Dir"

# inspect a volume
docker volume inspect named-volume-test
"Mountpoint": "/var/lib/docker/volumes/named-volume-test/_data"
ls -lht /var/lib/docker/volumes/named-volume-test/_data

echo "data" > /var/lib/docker/volumes/named-volume-test/_data/file.txt


# read write mount with named volume
docker container run --rm -it --volume named-volume-test:/data --hostname alpine --name alpine alpine:3.16.0 sh
docker container inspect alpine
ls -lth /data
cat /data/file.txt

echo "data" > /data/file.txt


docker container run -d -it --volume named-volume-test:/data --hostname alpine --name alpine alpine:3.16.0
# is the same as:
docker container run -d -it --volume named-volume-test:/data:rw --hostname alpine --name alpine alpine:3.16.0
# is the same with mount:
docker container run -d -it --mount source=named-volume-test,target=/data,readonly=false --hostname alpine --name alpine alpine:3.16.0


docker container exec -it alpine sh
mount | grep '/data'
# /dev/mapper/mint--vg-root on /data type ext4 (rw,relatime,errors=remount-ro,data=ordered)

rm -f /var/lib/docker/volumes/named-volume-test/_data/file.txt

docker container rm -f alpine


# read only mount with named volume
docker container run -d -it --volume named-volume-test:/data:ro --hostname alpine --name alpine alpine:3.16.0
# is the same with mount:
docker container run -d -it --mount source=named-volume-test,target=/data,readonly=true --hostname alpine --name alpine alpine:3.16.0

docker container exec -it alpine sh
rm -f /data/file.txt
# rm: can't remove '/data/file.txt': Read-only file system

mount | grep '/data'
# /dev/mapper/mint--vg-root on /data type ext4 (ro,relatime,errors=remount-ro,data=ordered)


# remove a volume
docker volume rm -f named-volume-test
```

## mapped volumes

```bash
CONTAINER_NAME='nginx'

docker container run --rm -d --name $CONTAINER_NAME --net bridge --publish 8080:80 nginx:1-alpine

# copy from container to local path
SRC_PATH=/usr/share/nginx/html/index.html
DEST_PATH=$PWD/index.html
docker cp $CONTAINER_NAME:$SRC_PATH $DEST_PATH

# copy from local path to container
SRC_PATH=$PWD/index.html
DEST_PATH=/usr/share/nginx/html/index.html
docker cp $SRC_PATH $CONTAINER_NAME:$DEST_PATH

# run a container with a mapped volume
docker container run --rm -d --name $CONTAINER_NAME --net bridge --publish 8080:80 -v $PWD/index.html:/usr/share/nginx/html/index.html:ro nginx:1-alpine

docker container rm -f $CONTAINER_NAME
```

## Prune/remove unused volumes

```bash
docker volume prune
```
