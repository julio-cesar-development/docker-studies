FROM alpine:3.16.0

WORKDIR /home/alpine

RUN apk add --update curl jq
RUN curl

ARG CEP_NUMBER
ENV CEP_NUMBER=$CEP_NUMBER

RUN curl -X GET --url "http://viacep.com.br/ws/$CEP_NUMBER/json"
