# Docker inside a container

```bash
export IMAGE_NAME_VERSION="juliocesarmidia/ubuntu_base:18.04"

docker container run --rm -it \
  --pid=host \
  --name ubuntu \
  --volume /usr/bin/docker:/usr/bin/docker \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  $IMAGE_NAME_VERSION sh

docker container inspect ubuntu --format="{{json .State.Pid}}"

ps -aux
```
