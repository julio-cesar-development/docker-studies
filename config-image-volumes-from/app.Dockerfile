FROM alpine:3.16.0

WORKDIR /app

COPY app.sh .

CMD ["sh", "-c", "source /config/env && . /app/app.sh"]

# docker image build --tag config-app-volumes-from:latest -f app.Dockerfile .
# docker container run --rm --volumes-from config-image-volumes-from --name config-app-volumes-from config-app-volumes-from:latest
