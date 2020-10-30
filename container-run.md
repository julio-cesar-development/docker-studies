# Container run

> Docs

[Command line options](https://docs.docker.com/engine/reference/commandline/run/#options)

> The docker container run command, performs the following steps:

```bash
- docker image pull

- docker container create

- docker container start

- docker container exec
```

Then let's simulate this:

```bash
# container run :: it pulls the image, create and start the container, and finally exec something into it
docker container run \
  -it \
  --name alpine \
  alpine:3.12.0 sh


# start with attach interactive (the container must be already created)
docker image pull alpine:3.12.0

docker container create \
  -it \
  --name alpine \
  alpine:3.12.0

docker container start alpine

docker exec -it alpine sh


# see logs
docker container logs -f --tail=50 alpine



# inspect
docker container inspect alpine | jq -r .


# start a container with attach and interactive
docker container start -a -i alpine

# stop a running container
docker container stop alpine


# remove force a container
docker container rm -f alpine



# run a container overwriting the entrypoint and CMD
docker container run --rm \
  -it --entrypoint "" \
  busybox:latest sh
```
