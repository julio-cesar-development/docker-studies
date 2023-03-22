FROM alpine:3.16.0

WORKDIR /config

RUN apk add --update curl jq

COPY env .

VOLUME "/config"

# docker image build --tag config-image-volumes-from:latest -f config.Dockerfile .
# docker container create --name config-image-volumes-from config-image-volumes-from:latest
