
> https://docs.docker.com/registry/deploying/


## local registry

```bash
docker container run -d -p 5000:5000 --restart always --hostname registry --name registry registry:2
docker container logs -f registry
docker container rm -f registry

docker info | grep 'Registry'
# Registry: https://index.docker.io/v1/

docker image pull alpine:3.16.0
# is the same as:
docker image pull docker.io/alpine:3.16.0

# tag an existing image pointing to local registry (localhost:5000)
docker image tag alpine:3.16.0 localhost:5000/alpine:3.16.0

# push to local registry
docker image push localhost:5000/alpine:3.16.0

docker images | awk '$2 ~ "alpine" {print $0}'

# remove and pull to test the registry
docker image rm localhost:5000/alpine:3.16.0
docker image pull localhost:5000/alpine:3.16.0

docker container run -it --rm --name alpine localhost:5000/alpine:3.16.0 sh

# clean up
docker image rm localhost:5000/alpine:3.16.0
docker container rm -f registry
```


## local registry with volume for persistency

```bash
docker image inspect registry:2
"Volumes": {
  "/var/lib/registry": {}
}

docker volume create registry-data
docker container run -d -p 5000:5000 --volume registry-data:/var/lib/registry --restart always --hostname registry --name registry registry:2
docker container logs -f registry

# clean up
docker image rm localhost:5000/alpine:3.16.0
docker container rm -f registry
docker volume rm -f registry-data
```


## local registry with authentication

```bash
REGISTRY_USER="registryuser"
REGISTRY_PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%&*(){}[]+-' | fold -w 16 | tr '[:upper:]' '[:lower:]' | head -n 1)
echo "$REGISTRY_PASSWD"
# e.g.: #cavmvlsyzoopegj
REGISTRY_PASSWD="#cavmvlsyzoopegj"

mkdir -p auth
# htpasswd using bcrypt
htpasswd -Bbn "$REGISTRY_USER" "$REGISTRY_PASSWD" > auth/passwd
cat auth/passwd
# e.g.: registryuser:$2y$05$.1NYos96Mdv5msWiA/Bdq.ElGnDkUbpGTg6IOV3ykDlgJ4X0CgMaO

docker container run -d \
  -p 5000:5000 \
  --volume registry-data:/var/lib/registry \
  --restart=always \
  --hostname registry \
  --name registry \
  -v "$PWD/auth":/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/passwd" \
  registry:2

docker container logs -f registry

docker image tag alpine:3.16.0 localhost:5000/alpine:3.16.0

docker image push localhost:5000/alpine:3.16.0
# unauthorized: authentication required

# login
echo "$REGISTRY_PASSWD" | docker login -u "$REGISTRY_USER" --password-stdin localhost:5000

docker image push localhost:5000/alpine:3.16.0
# Pushed

# clean up
docker image rm localhost:5000/alpine:3.16.0
docker container rm -f registry
docker volume rm -f registry-data
```


## local registry with certificate

```bash
mkdir -p certs
# generating a self signed certificate
openssl genrsa -out certs/registry.key 4096
openssl req -new -key certs/registry.key -x509 -out certs/registry.crt

# example inputs:
Country Name (2 letter code) [AU]: BR
State or Province Name (full name) [Some-State]: PR
Locality Name (eg, city) []: Curitiba
Organization Name (eg, company) [Internet Widgits Pty Ltd]: Blackdevs
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []: registry.local
Email Address []:

# output files:
# certs/registry.key
# certs/registry.crt

echo '127.0.0.1 registry.local' >> /etc/hosts
cat /etc/hosts | grep 'registry.local'
nslookup registry.local

docker container run -d \
  -p 5000:5000 \
  --volume registry-data:/var/lib/registry \
  --restart=always \
  --hostname registry \
  --name registry \
  -v "$PWD/certs":/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  registry:2

docker container logs -f registry

# testing registry connection
curl -k -i https://registry.local:5000

docker image tag alpine:3.16.0 registry.local:5000/alpine:3.16.0

docker image push registry.local:5000/alpine:3.16.0

# clean up
docker image rm registry.local:5000/alpine:3.16.0
docker container rm -f registry
docker volume rm -f registry-data
```
