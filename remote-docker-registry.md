

## registry on aws with EC2

## certs

```bash
# DOMAIN="yourdomain.com.br"

mkdir -p certs
openssl genrsa -out certs/registry.key 4096
openssl req -new -key certs/registry.key -x509 -out certs/registry.crt

Country Name (2 letter code) [AU]: BR
State or Province Name (full name) [Some-State]: PR
Locality Name (eg, city) []: Curitiba
Organization Name (eg, company) [Internet Widgits Pty Ltd]: Blackdevs
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []: registry.yourdomain.com.br
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
REGISTRY_PASSWD="#cavmvlsyzoopegj"

mkdir -p auth
# htpasswd using bcrypt
htpasswd -Bbn "$REGISTRY_USER" "$REGISTRY_PASSWD" > auth/passwd
cat auth/passwd
# e.g.: registryuser:$2y$05$YQNBNIFsLpG4G9lcYq.c4.6sJqDf6Gwfl7BvTLWYA3Gw9up.fmQxS
```

## create a s3 bucket

```bash
# BUCKET_NAME="registry-aws-bucket-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | tr '[:upper:]' '[:lower:]' | head -n 1)"
BUCKET_NAME="registry-aws-bucket-tpreqmxi"
echo "$BUCKET_NAME"

BUCKET_REGION="us-east-1"
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$BUCKET_REGION" --acl private

# copy files to bucket
aws s3 cp certs/registry.key s3://$BUCKET_NAME/certs/registry.key
aws s3 cp certs/registry.crt s3://$BUCKET_NAME/certs/registry.crt
aws s3 cp auth/passwd s3://$BUCKET_NAME/auth/passwd
```

## create a policy

```bash
name: registry-aws-s3-access-policy

cat > registry-aws-s3-access-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws iam create-policy \
  --policy-name registry-aws-s3-access-policy \
  --policy-document file://registry-aws-s3-access-policy.json
```

## create a role

```bash
name: registry-aws-s3-access-role

# trust entities: ec2
cat > registry-aws-s3-access-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
EOF

aws iam create-role \
  --role-name registry-aws-s3-access-role \
  --assume-role-policy-document file://registry-aws-s3-access-trust-policy.json

export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws iam attach-role-policy \
  --role-name registry-aws-s3-access-role \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/registry-aws-s3-access-policy
```

## create ec2

```bash
name: registry-aws
AMI: ecs optimized ami-07da26e39622a03dc (it has docker already installed and running)
size: t3.micro
iam instance profile: registry-aws-s3-access-role
security group: create new registry-aws-sg (allow 22 and 5000)
key Pair: create new (id_rsa) and download it
  chmod 400 id_rsa.pem

user data:
#!/bin/bash

BUCKET_NAME="<BUCKET_NAME>"
sudo mkdir -p /home/ec2-user/certs/ && sudo mkdir -p /home/ec2-user/auth/
sudo pip3 install --upgrade --user awscli
export PATH="$HOME/.local/bin:$PATH"
aws s3 cp s3://$BUCKET_NAME/auth/passwd /home/ec2-user/auth/passwd
aws s3 cp s3://$BUCKET_NAME/certs/registry.key /home/ec2-user/certs/registry.key
aws s3 cp s3://$BUCKET_NAME/certs/registry.crt /home/ec2-user/certs/registry.crt
sudo chown -R ec2-user:ec2-user /home/ec2-user/

docker container run -d \
  -p 5000:5000 \
  --volume registry-data:/var/lib/registry \
  --restart=always \
  --hostname registry \
  --name registry \
  -v /home/ec2-user/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -v /home/ec2-user/auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/passwd" \
  registry:2
```

## update dns registry with ec2 ip

## access the registry container

```bash
# access ec2 console to check
EC2_IP="<COPY_FROM_CONSOLE>"
ssh -i id_rsa.pem ec2-user@$EC2_IP

docker container ps
docker container logs -f registry
cat /var/log/cloud-init-output.log

ls -lth /var/lib/docker/volumes/registry-data/_data/docker/registry/v2/repositories/
```

## configuration on local machine

```bash
nslookup registry.yourdomain.com.br
nc -v registry.yourdomain.com.br 5000

# update on local machine to allow insecure registry (because of self signed certificate)
systemctl cat docker.service
vim /lib/systemd/system/docker.service
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecStart=/usr/bin/dockerd --insecure-registry registry.yourdomain.com.br:5000 -H fd:// --containerd=/run/containerd/containerd.sock

systemctl daemon-reload
systemctl restart docker.service
docker info | grep -A2 'Insecure Registries'


docker image tag alpine:3.16.0 registry.yourdomain.com.br:5000/alpine:3.16.0

docker image push registry.yourdomain.com.br:5000/alpine:3.16.0
# unauthorized: authentication required


# login
echo "$REGISTRY_PASSWD" | docker login -u "$REGISTRY_USER" --password-stdin registry.yourdomain.com.br:5000

cat ~/.docker/config.json | grep 'registry.yourdomain.com.br:5000'

docker image push registry.yourdomain.com.br:5000/alpine:3.16.0
# Pushed


docker images | awk '$2 ~ "alpine" {print $0}'

docker image rm registry.yourdomain.com.br:5000/alpine:3.16.0

docker image pull registry.yourdomain.com.br:5000/alpine:3.16.0

docker logout registry.yourdomain.com.br:5000
```
