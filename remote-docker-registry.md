

## registry on aws with EC2

## certs

```bash
DOMAIN="yourdomain.com.br"

mkdir -p certs
openssl genrsa -out certs/registry.key 4096
openssl req -new -key certs/registry.key -x509 -out certs/registry.crt

Country Name (2 letter code) [AU]: BR
State or Province Name (full name) [Some-State]: PR
Locality Name (eg, city) []: Curitiba
Organization Name (eg, company) [Internet Widgits Pty Ltd]: Blackdevs
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []: registry.$DOMAIN
Email Address []:

# output files:
# certs/registry.key
# certs/registry.crt
```

## auth

```bash
REGISTRY_USER="registryuser"
REGISTRY_PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%&*(){}[]+-' | fold -w 16 | tr '[:upper:]' '[:lower:]' | head -n 1)
echo "$REGISTRY_PASSWD"
# e.g.: #cavmvlsyzoopegj

mkdir -p auth
# htpasswd using bcrypt
htpasswd -Bbn "$REGISTRY_USER" "$REGISTRY_PASSWD" > auth/passwd
cat auth/passwd
# e.g.: registryuser:$2y$05$YQNBNIFsLpG4G9lcYq.c4.6sJqDf6Gwfl7BvTLWYA3Gw9up.fmQxS
```

## create ec2

```bash
Size: t3.micro
AMI: ecs optimized ami-07da26e39622a03dc (it has docker already installed and running)
Key Pair: create new (id_rsa) and download it
chmod 400 id_rsa.pem

security group: create new registry-aws-sg (allow 22 and 5000)

user data:
#!/bin/bash
sudo mkdir -p /home/ec2-user/certs/ && sudo mkdir -p /home/ec2-user/auth/
sudo chown -R ec2-user:ec2-user /home/ec2-user/

# launch the instance

EC2_IP="<COPY_FROM_CONSOLE>"

# update dns registry with ec2 ip
```

## copy files to ec2

```bash
scp -i id_rsa.pem $PWD/certs/* ec2-user@$EC2_IP:/home/ec2-user/certs/
scp -i id_rsa.pem $PWD/auth/* ec2-user@$EC2_IP:/home/ec2-user/auth/
```

## run the registry container

```bash
# access ec2 console
ssh -i id_rsa.pem ec2-user@$EC2_IP

docker volume create registry-data
cd /home/ec2-user
docker container run -d \
  -p 5000:5000 \
  --volume registry-data:/var/lib/registry \
  --restart=always \
  --hostname registry \
  --name registry \
  -v "$PWD/certs":/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -v "$PWD/auth":/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/passwd" \
  registry:2

docker container logs -f registry

ls -lth /var/lib/docker/volumes/registry-data/_data/docker/registry/v2/repositories/

nslookup registry.$DOMAIN
nc -v registry.$DOMAIN 5000

# update on local machine to allow insecure registry (because of self signed certificate)
systemctl cat docker.service
vim /lib/systemd/system/docker.service
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecStart=/usr/bin/dockerd --insecure-registry registry.$DOMAIN:5000 -H fd:// --containerd=/run/containerd/containerd.sock

systemctl daemon-reload
systemctl restart docker.service
docker info | grep -A2 'Insecure Registries'


docker image tag alpine:3.16.0 registry.$DOMAIN:5000/alpine:3.16.0

docker image push registry.$DOMAIN:5000/alpine:3.16.0
# unauthorized: authentication required


# login
echo "$REGISTRY_PASSWD" | docker login -u "$REGISTRY_USER" --password-stdin registry.$DOMAIN:5000

cat ~/.docker/config.json | grep 'registry.$DOMAIN:5000'

docker image push registry.$DOMAIN:5000/alpine:3.16.0
# Pushed


docker images | awk '$2 ~ "alpine" {print $0}'

docker image rm registry.$DOMAIN:5000/alpine:3.16.0

docker image pull registry.$DOMAIN:5000/alpine:3.16.0
```
