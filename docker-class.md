# Docker Class

```bash

# https://hub.docker.com/_/busybox

# fazer pull de imagem
# orientavel sempre utilizar uma tag especifica
docker image pull busybox
docker image pull busybox:1.35.0

# listar imagens
docker image ls

# inspecionar imagem
docker image inspect busybox
docker image inspect busybox:latest

"Entrypoint": null,
"Cmd": [
    "/bin/sh",
    "-c",
    "#(nop) ",
    "CMD [\"sh\"]"
],


# cria o container mas não executa
docker container create -it --name busybox busybox

# roda/para container já criado
docker container start busybox
docker container stop busybox

# pause e unpause
docker container pause busybox
docker container unpause busybox


# "docker container run" faz pull da imagem, cria o container e faz start
# "sh" no final do comando define o command que será passado ao container ao iniciar
docker container run -it --name busybox busybox sh

# --rm (remove container ao parar a execução)
docker container run --rm -it --name busybox busybox

# -d (detached) desanexar - em background
docker container run -it -d --name busybox busybox

# em background e para remover ao parar a execução
docker container run --rm -it -d --name busybox busybox


# --network=host define que usará a mesma rede do host
docker container run --rm -it -d --name busybox --network host busybox



# testes com alpine
docker container run --rm -it --name alpine alpine:3.16.0

# buildar imagem
# "./CustomAlpine/" é o build context
docker image build --tag custom-alpine:latest --build-arg CEP_NUMBER=81130220 ./CustomAlpine/

# executar container buildado
docker container run --rm --name custom-alpine custom-alpine:latest



# executar comando no container depois de iniciado
docker container exec -it busybox sh
docker container exec -it busybox /bin/sh


# listar containers
docker container ps
# listar todos containers (mesmo containers parados)
docker container ps -a

# remover container (por nome ou por hash)
docker container rm -f busybox
docker container rm -f 67efad47fbae

```
