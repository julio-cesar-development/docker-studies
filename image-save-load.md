# Image - save and load

> Full image format

`[REGISTRY_DOMAIN]/[REPOSITORY_PROJECT]/[IMAGE]:[TAG]`

> docker.io/juliocesarmidia/go-micro-api:v1.0.0

```bash
export IMAGE_NAME_VERSION="juliocesarmidia/go-micro-api:v1.0.0"

docker image pull $IMAGE_NAME_VERSION
docker images | grep juliocesarmidia/go-micro-api

# exporting images (docker save)
docker save --output dockerimage.tar $IMAGE_NAME_VERSION
# or
docker save $IMAGE_NAME_VERSION > dockerimage.tar

# compact image to gz
tar czvf dockerimage.tar.gz dockerimage.tar

# remove pulled image
docker image rm -f $IMAGE_NAME_VERSION

# extract image from gz
tar xzvf dockerimage.tar.gz

# copy with scp
scp -i <privatekey.pem> ./dockerimage.tar <username>@<hostname>:/tmp/dockerimage.tar
# e.g:
scp -i ~/.ssh/id_rsa ./dockerimage.tar ubuntu@127.0.0.1:/tmp/dockerimage.tar

# importing image (docker load)
docker load -i dockerimage.tar
# or
docker load < dockerimage.tar

# advanced: see files on each layer of the image
mkdir -p ./dockerimage/ && \
  tar xf ./dockerimage.tar --ignore-command-error -C ./dockerimage/

pushd ./dockerimage/
for layer in ./*; do
  ls -lth $layer

  if [ -f $layer/layer.tar ]; then
    pushd $layer
    # tar xf layer.tar # extract files
    tar tf layer.tar # only list files
    popd
  fi
done
popd
```
