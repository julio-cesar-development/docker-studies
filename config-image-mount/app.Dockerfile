FROM alpine:3.16.0

WORKDIR /app

COPY app.sh .

CMD ["sh", "-c", "source /config/env && . /app/app.sh"]

# docker image build --tag config-app-mount:latest -f app.Dockerfile .
# docker container run --rm --volume config-volume:/config --name config-app-mount config-app-mount:latest

# docker volume inspect config-volume
# docker volume rm -f config-volume
