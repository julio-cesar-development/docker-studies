# Docker-compose variables

> Variables from Host Machine environment overwrites .env file
> it will create a default network when any network is set

```bash
docker-compose up -d


docker-compose-variables is the COMPOSE_PROJECT_NAME
# Creating network "docker-compose-variables_default" with the default driver

docker network inspect docker-compose-variables_default | jq


docker-compose ps

docker-compose logs -f api_v1


curl http://localhost:9000
# TEST v2
```
