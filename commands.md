# Docker commands

```bash
#### docker ####

docker info

#### output ####
Docker Root Dir: /var/lib/docker
Registry: https://index.docker.io/v1/

Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog

Server:
  Containers: 13
    Running: 9
    Paused: 0
    Stopped: 4
  Images: 435
#### output ####


# logs of docker service
sudo journalctl -fu docker -n0


# clean all unused stuff
docker system prune


# docker stats
docker stats --all
docker stats --no-stream

# example
docker container run \
  -it -d \
  --name alpine \
  -m 512MiB \
  alpine:3.12.0 sh -c "while true; do sleep 60; done"

docker stats --no-trunc alpine
docker container rm -f alpine



# see image instructions history
docker image history --no-trunc alpine:3.12.0





#### docker-compose ####

# project name variable
export COMPOSE_PROJECT_NAME=
unset COMPOSE_PROJECT_NAME


# compose file name variable
export COMPOSE_FILE=docker-compose.yml:docker-compose.prod.yml

# docker-compose up with a different docker-compose file
docker-compose -f COMPOSE_FILE -d up

# default override docker-compose
docker-compose.override.yml



# see docker-compose configuration
docker-compose config

# see docker-compose service
docker-compose config --services



# docker-compose run (execute a CMD on the service)
docker-compose run $SERVICE_NAME sh



# '--scale' start more than 1 instance for the services
# it couldn't have `container_name` on service definition
docker-compose up -d --scale app=3
```
