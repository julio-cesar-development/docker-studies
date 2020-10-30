# Docker-compose named volumes

```bash
docker-compose up -d


docker volume ls


export COMPOSE_PROJECT_NAME="docker-compose-named-volumes"
${COMPOSE_PROJECT_NAME}_appv2

docker-compose-named-volumes_appv2



docker container inspect app | jq -r '.[].Mounts'

"Mounts": [
  {
    "Type": "volume",
    "Name": "docker-compose-named-volumes_appv2",
    "Source": "/var/lib/docker/volumes/docker-compose-named-volumes_appv2/_data",
    "Destination": "/appv2",
    "Driver": "local",
    "Mode": "rw",
    "RW": true,
    "Propagation": ""
  },
  {
    "Type": "bind",
    "Source": "/home/julio/Documentos/docker-studies/docker-compose-named-volumes/appv1",
    "Destination": "/appv1",
    "Mode": "rw",
    "RW": true,
    "Propagation": "rprivate"
  }
]

ls -lth /var/lib/docker/volumes/*/_data


ls -lth /var/lib/docker/volumes/docker-compose-named-volumes_appv2/_data

cat /var/lib/docker/volumes/docker-compose-named-volumes_appv2/_data/index.html




docker container logs -f app
# or
tail -f $(docker container inspect app | jq -r '.[].LogPath')




curl http://localhost:9000/v1/
# APP V1

curl http://localhost:9000/v2/
# APP v2
```
