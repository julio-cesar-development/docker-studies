# Image save and load

> The full image format

`[REGISTRY_DOMAIN]/[REPOSITORY_PROJECT]/[IMAGE]:[TAG]`

Examples:

> docker.io/juliocesarmidia/http-simple-api:v1.0.0

> gcr.io/juliocesarmidia/http-simple-api:v1.0.0

```bash
export IMAGE_NAME_VERSION="juliocesarmidia/http-simple-api:v1.0.0"

# exporting images (docker save)
docker save --output dockerimage.tar $IMAGE_NAME_VERSION
# or
docker save $IMAGE_NAME_VERSION > dockerimage.tar


# see files on each layer of the image
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


# importing images (docker load)
docker load -i dockerimage.tar
# or
docker load < dockerimage.tar
```
