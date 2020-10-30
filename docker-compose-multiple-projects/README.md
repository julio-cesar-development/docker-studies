# Docker-compose multiple projects

```bash
# set project name
export COMPOSE_PROJECT_NAME="shared_volumes"


#### v1
cd v1

# start MySQL
docker-compose up -d mysql-db


# see volume info
docker volume ls

docker volume inspect ${COMPOSE_PROJECT_NAME}_mysql-volume

ls -lth /var/lib/docker/volumes/${COMPOSE_PROJECT_NAME}_mysql-volume/_data


# start app
docker-compose up -d app_v1

docker container logs -f app_v1



#### v2
# here it will use the existing MySQL, once it will see the containers as being part of the same project

cd v2

# start app
docker-compose up -d app_v2


docker container logs -f app_v2


# cleanup
docker volume rm ${COMPOSE_PROJECT_NAME}_mysql-volume
unset COMPOSE_PROJECT_NAME
```
