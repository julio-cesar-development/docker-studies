FROM juliocesarmidia/ubuntu_base:18.04

WORKDIR /app

COPY ./appv1 /app/v1
COPY ./appv2 /app/v2

EXPOSE 9000

CMD ["python3", "-m", "http.server", "9000" ]
