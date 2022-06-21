#!/bin/sh

curl --silent -X GET --url "http://viacep.com.br/ws/$CEP_NUMBER/json" > /home/alpine/output.json

exec "$@"
