# Docker copy

> Docker copy from container to local machine

```bash
CONTAINER_NAME='api'

SRC_PATH=/etc/apache2/apache2.conf
DEST_PATH=./apache2.bkp.conf

docker cp $CONTAINER_NAME:$SRC_PATH $DEST_PATH
```

> Docker copy from local machine to container

```bash
CONTAINER_NAME='api'

SRC_PATH=/root/cnpjs-duplicados-prod.js
DEST_PATH=/cnpjs-duplicados-prod.js

docker cp $SRC_PATH $CONTAINER_NAME:$DEST_PATH
```
