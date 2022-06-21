FROM alpine:3.16.0

WORKDIR /home/alpine

RUN apk add --update --no-cache curl jq
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["cat", "/home/alpine/output.json"]
