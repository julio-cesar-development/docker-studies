FROM juliocesarmidia/ubuntu_base:18.04

WORKDIR /app
COPY docker-entrypoint.sh .
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
