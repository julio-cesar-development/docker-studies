# Docker volumes

## list volumes

```bash
docker volume ls
```

## named volumes

```bash
# create a new volume called "my-vol"
docker volume create my-vol


# inspect a volume
docker volume inspect my-vol
"Mountpoint": "/var/lib/docker/volumes/my-vol/_data"
ls -lht /var/lib/docker/volumes/my-vol/_data

echo "data" > /var/lib/docker/volumes/my-vol/_data/file.txt


# read write mount with named volume
docker container run --rm -it --volume my-vol:/data --hostname alpine --name alpine alpine:3.16.0 sh
ls -lth /data
cat /data/file.txt

docker container run -d -it --volume my-vol:/data --hostname alpine --name alpine alpine:3.16.0
docker container run -d -it --volume my-vol:/data:rw --hostname alpine --name alpine alpine:3.16.0

docker container exec -it alpine sh
mount | grep '/data'
# /dev/mapper/mint--vg-root on /data type ext4 (rw,relatime,errors=remount-ro,data=ordered)

rm -f /var/lib/docker/volumes/my-vol/_data/file.txt

docker container rm -f alpine


# read only mount with named volume
docker container run -d -it --volume my-vol:/data:ro --hostname alpine --name alpine alpine:3.16.0
docker container exec -it alpine sh
rm -f /data/file.txt
# rm: can't remove '/data/file.txt': Read-only file system

mount | grep '/data'
# /dev/mapper/mint--vg-root on /data type ext4 (ro,relatime,errors=remount-ro,data=ordered)


# remove a volume
docker volume rm -f my-vol

```

## maped volumes

```bash
docker container run --rm -d --name nginx --net bridge --publish 8080:80 nginx:1-alpine

docker container run --rm -d --name nginx --net bridge --publish 8080:80 -v $PWD/index.html:/usr/share/nginx/html/index.html:ro nginx:1-alpine


CONTAINER_NAME='nginx'
SRC_PATH=$PWD/index.html
DEST_PATH=/usr/share/nginx/html/index.html
docker cp $SRC_PATH $CONTAINER_NAME:$DEST_PATH

docker cp nginx:$PWD/index.html /usr/share/nginx/html/index.html
```
