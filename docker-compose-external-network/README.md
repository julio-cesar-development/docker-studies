# Docker-compose variables

> Variables from Host Machine environment overwrites .env file
> it will create a default network when any network is set

```bash
# docker bridge network default
ip -4 a show docker0
# network 172.17.0.1/16


docker network create \
  --subnet 172.100.0.0/24 \
  --gateway 172.100.0.1 \
  --driver bridge \
  custom-external-net

docker network ls

docker network inspect custom-external-net | jq -r .


docker-compose up -d


docker-compose ps

docker-compose logs -f api_v1



docker container inspect api_v1 | jq -r '.[].NetworkSettings'

docker container inspect api_v1 | jq -r '.[].Config'



curl http://localhost:9000
# API V1

curl http://172.100.0.2:9000
# API V1


# cleanup
docker network rm custom-external-net
```
