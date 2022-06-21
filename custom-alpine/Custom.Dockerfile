FROM alpine:3.16.0

WORKDIR /home/alpine

RUN apk add --update --no-cache curl jq

ARG CEP_NUMBER
ENV CEP_NUMBER=$CEP_NUMBER

RUN echo "http://viacep.com.br/ws/$CEP_NUMBER/json"

RUN curl --silent -X GET --url "http://viacep.com.br/ws/$CEP_NUMBER/json" > /home/alpine/output.json

CMD ["cat", "/home/alpine/output.json"]
