# Docker-compose variables

> Variables from Host Machine environment overwrites .env file
> it will create a default network when any network is set

```bash
ip -4 a show docker0
# network 172.17.0.1/16


docker network create \
  --subnet 172.19.100.0/24 \
  --gateway 172.19.100.1 \
  --driver bridge \
  custom-external-net

docker network inspect custom-external-net | jq

docker network rm custom-external-net



docker-compose up -d


docker-compose-variables is the COMPOSE_PROJECT_NAME
# Creating network "docker-compose-variables_default" with the default driver

docker network inspect docker-compose-variables_default


docker-compose ps

docker-compose logs -f api_v1



docker container inspect api_v1 | jq -r '.[].NetworkSettings'

docker container inspect api_v1 | jq -r '.[].Config'



curl http://localhost:9000
# API V1
```
