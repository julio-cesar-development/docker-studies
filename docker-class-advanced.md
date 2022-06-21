# Docker Class advanced

```bash

# modo privilegiado (--privileged) dá total capacidades ao container (capabilities)
# --pid=host faz compartilhamento do namespace pid com o host
docker container run --rm -it --name busybox --privileged --network host --pid=host busybox
ps aux


# obter PID do container
CONTAINER_PID=$(docker container inspect busybox --format="{{json .State.Pid}}")
echo $CONTAINER_PID
ps -aux | grep $CONTAINER_PID | grep -v grep

ls /proc/$CONTAINER_PID/ns/
readlink /proc/$CONTAINER_PID/ns/pid


# rastrear syscalls executadas pela criação do container
strace -t -p $CONTAINER_PID

strace -t docker container run -it -d --name busybox --network host busybox sh

strace -t -e clone,getpid docker container run -it -d --name busybox --network host busybox sh


# acessar os namespaces do container
nsenter --pid=/proc/$CONTAINER_PID/ns/pid \
  --net=/proc/$CONTAINER_PID/ns/net \
  --uts=/proc/$CONTAINER_PID/ns/uts \
  --ipc=/proc/$CONTAINER_PID/ns/ipc \
  --mount=/proc/$CONTAINER_PID/ns/mnt \
  --cgroup=/proc/$CONTAINER_PID/ns/cgroup sh

readlink /proc/self/ns/pid

```
