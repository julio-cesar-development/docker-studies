FROM alpine:3.16.0

WORKDIR /config-src

RUN apk add --update curl jq

COPY env .

ENTRYPOINT ["sh", "-c", "cp /config-src/* $1", "--"]

# docker image build --tag config-image-mount:latest -f config.Dockerfile .
# docker container run --rm --volume config-volume:/config --name config config-image-mount:latest /config

# docker volume inspect config-volume
# cat /var/lib/docker/volumes/config-volume/_data/env
